import 'package:boty_frog/data/datasources/ai_response_claude_datasource.dart';
import 'package:boty_frog/domain/entities/business_info_entity.dart';
import 'package:boty_frog/domain/entities/contact_entity.dart';
import 'package:boty_frog/domain/entities/conversation_entity.dart';
import 'package:boty_frog/domain/entities/shipping_zone_entity.dart';
import 'package:boty_frog/domain/entities/tenant_config_entity.dart';
import 'package:boty_frog/domain/usecases/get_business_info_usecase.dart';
import 'package:boty_frog/domain/usecases/search_products_usecase.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockDio extends Mock implements Dio {}

class MockSearchProductsUsecase extends Mock implements SearchProductsUsecase {}

class MockGetBusinessInfoUsecase extends Mock
    implements GetBusinessInfoUsecase {}

void main() {
  late MockDio mockDio;
  late MockSearchProductsUsecase mockSearchProducts;
  late MockGetBusinessInfoUsecase mockGetBusinessInfo;
  late AiResponseClaudeDatasource datasource;

  final tenant = TenantConfigEntity(
    businessId: 'biz_123',
    phoneId: 'phone_123',
    apiToken: 'token_123',
    verifyToken: 'vtoken_123',
    aiApiKey: 'ai_123',
    brandName: 'brand_123',
    catalogUrl: 'cat_123',
    businessType: 'type_123',
    toneStyle: 'tone_123',
    botName: 'bot_123',
  );

  final conversation = ConversationEntity(
    id: 'conv_123',
    contact: ContactEntity(name: 'André', phoneId: 'user_123'),
    messages: const [],
    unreadCount: 0,
  );

  setUp(() {
    mockDio = MockDio();
    mockSearchProducts = MockSearchProductsUsecase();
    mockGetBusinessInfo = MockGetBusinessInfoUsecase();

    datasource = AiResponseClaudeDatasource(
      dio: mockDio,
      searchProductsUsecase: mockSearchProducts,
      getBusinessInfoUsecase: mockGetBusinessInfo,
    );
  });

  test(
      'should execute multiple tools in parallel '
      'and consolidate response', () async {
    final firstResponse = Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(),
      data: {
        'stop_reason': 'tool_use',
        'content': [
          {
            'type': 'tool_use',
            'id': 'toolu_2',
            'name': 'obtener_metodos_pago',
            'input': <String, dynamic>{},
          },
          {
            'type': 'tool_use',
            'id': 'toolu_3',
            'name': 'obtener_metodos_envio',
            'input': <String, dynamic>{},
          }
        ],
      },
    );

    final secondResponse = Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(),
      data: {
        'stop_reason': 'end_turn',
        'content': [
          {
            'type': 'text',
            'text': 'Puedes pagar con Yape y el envío cuesta 10 soles.',
          }
        ],
      },
    );

    when(() => mockGetBusinessInfo('biz_123'))
        .thenAnswer((_) async => BusinessInfoEntity(
              paymentMethods: ['Yape'],
              shippingZones: [
                ShippingZoneEntity(
                  id: 'zone_1',
                  name: 'Lima',
                  price: 10,
                  description: 'Envio Lima',
                ),
              ],
            ));

    var callCount = 0;
    when(() => mockDio.post<Map<String, dynamic>>(
          any(),
          options: any(named: 'options'),
          data: any(named: 'data'),
        )).thenAnswer((_) async {
      callCount++;
      if (callCount == 1) {
        return firstResponse;
      } else {
        return secondResponse;
      }
    });

    final result = await datasource.generateHistoryBasedResponse(
      conversation,
      tenant,
    );

    expect(
      result.responseText,
      equals('Puedes pagar con Yape y el envío cuesta 10 soles.'),
    );
    expect(result.shouldDeactivateBot, isFalse);
    expect(callCount, equals(2));

    verifyNever(
      () => mockSearchProducts(
        businessId: any(named: 'businessId'),
        query: any(named: 'query'),
      ),
    );
    verify(() => mockGetBusinessInfo('biz_123')).called(2);
  });

  test(
      'hands off to agent and flags bot deactivation on '
      'derivar_consulta_producto', () async {
    final handoffResponse = Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(),
      data: {
        'stop_reason': 'tool_use',
        'content': [
          {
            'type': 'tool_use',
            'id': 'toolu_1',
            'name': 'derivar_consulta_producto',
            'input': <String, dynamic>{'query': 'pantalón casual negro'},
          },
        ],
      },
    );

    var callCount = 0;
    when(() => mockDio.post<Map<String, dynamic>>(
          any(),
          options: any(named: 'options'),
          data: any(named: 'data'),
        )).thenAnswer((_) async {
      callCount++;
      return handoffResponse;
    });

    final result = await datasource.generateHistoryBasedResponse(
      conversation,
      tenant,
    );

    expect(result.shouldDeactivateBot, isTrue);
    expect(
      result.responseText,
      contains('Se te derivará con un agente especializado'),
    );
    expect(result.responseText, contains(tenant.catalogUrl));
    expect(callCount, equals(1));
    verifyNever(
      () => mockSearchProducts(
        businessId: any(named: 'businessId'),
        query: any(named: 'query'),
      ),
    );
  });
}
