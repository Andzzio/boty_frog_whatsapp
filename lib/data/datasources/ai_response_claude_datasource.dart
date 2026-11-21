import 'dart:convert';
import 'package:boty_frog/data/constants/prompt_template.dart';
import 'package:boty_frog/data/models/ai_response_model.dart';
import 'package:boty_frog/data/models/message_model.dart';
import 'package:boty_frog/domain/datasources/ai_response_remote_datasource.dart';
import 'package:boty_frog/domain/entities/conversation_entity.dart';
import 'package:boty_frog/domain/entities/message_entity.dart';
import 'package:boty_frog/domain/entities/tenant_config_entity.dart';
import 'package:boty_frog/domain/usecases/get_business_info_usecase.dart';
import 'package:boty_frog/domain/usecases/search_products_usecase.dart';
import 'package:boty_frog/domain/utils/handoff_message.dart';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

/// Claude-backed implementation of [AiResponseRemoteDatasource].
class AiResponseClaudeDatasource implements AiResponseRemoteDatasource {
  /// Constructs an [AiResponseClaudeDatasource] instance.
  AiResponseClaudeDatasource({
    required Dio dio,
    required SearchProductsUsecase searchProductsUsecase,
    required GetBusinessInfoUsecase getBusinessInfoUsecase,
  })  : _dio = dio,
        _searchProductsUsecase = searchProductsUsecase,
        _getBusinessInfoUsecase = getBusinessInfoUsecase;

  final Dio _dio;
  // Kept for DI compatibility while product search is disabled.
  // ignore: unused_field
  final SearchProductsUsecase _searchProductsUsecase;
  final GetBusinessInfoUsecase _getBusinessInfoUsecase;
  static final _logger = Logger('AiResponseClaudeDatasource');

  String get _url => 'https://api.anthropic.com/v1/messages';
  String get _model => 'claude-haiku-4-5';

  @override
  Future<AiResponseModel> generateHistoryBasedResponse(
    ConversationEntity conversation,
    TenantConfigEntity tenant,
  ) async {
    final allMessages = conversation.messages;
    final recentMessages = allMessages.length > 20
        ? allMessages.sublist(allMessages.length - 20)
        : allMessages;

    final messages = recentMessages
        .map(
          (msg) => MessageModel.fromEntity(msg).toClaudeJson(conversation.id),
        )
        .toList();

    final contactName = conversation.contact.name;
    messages.insert(0, {
      'role': 'user',
      'content': 'Mi nombre es $contactName',
    });

    final tools = [
      {
        'name': 'derivar_consulta_producto',
        'description':
            'Deriva inmediatamente la conversación a un agente especializado '
            'y desactiva el bot cuando el cliente pregunta por un producto '
            'específico, prenda, precio, stock, tallas, colores, modelos o '
            'disponibilidad.',
        'input_schema': {
          'type': 'object',
          'properties': {
            'query': {
              'type': 'string',
              'description': 'El producto o prenda sobre el cual pregunta el '
                  'cliente.'
            }
          },
          'required': ['query']
        }
      },
      {
        'name': 'obtener_metodos_pago',
        'description':
            'Obtiene los métodos de pago aceptados por el negocio. '
            'Úsala cuando el cliente pregunte por formas de pago, '
            'cuentas bancarias, transferencias, efectivo, o billeteras '
            'digitales peruanas como Yape, Plin, BCP, BBVA, Interbank '
            'o Yapear.',
        'input_schema': {
          'type': 'object',
          'properties': <String, dynamic>{}
        }
      },
      {
        'name': 'obtener_metodos_envio',
        'description':
            'Obtiene los métodos y zonas de envío con sus respectivos '
            'costos. Úsala cuando el cliente pregunte por envíos, '
            'entregas, delivery, costos de despacho, envíos a '
            'provincia, Olva Courier o Shalom.',
        'input_schema': {
          'type': 'object',
          'properties': <String, dynamic>{}
        }
      }
    ];

    try {
      var response = await _dio.post<Map<String, dynamic>>(
        _url,
        options: Options(
          headers: {
            'x-api-key': tenant.aiApiKey,
            'anthropic-version': '2023-06-01',
            'content-type': 'application/json',
          },
        ),
        data: {
          'model': _model,
          'max_tokens': 1024,
          'cache_control': {'type': 'ephemeral'},
          'system': PromptTemplate.build(tenant),
          'tools': tools,
          'messages': messages,
        },
      );

      final stopReason = response.data?['stop_reason'] as String?;
      var contents = (response.data?['content'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();

      if (stopReason == 'tool_use') {
        final toolUseBlocks = contents
            .where((block) => block['type'] == 'tool_use')
            .toList();

        final requestsProductHandoff = toolUseBlocks.any(
          (block) =>
              block['name'] == 'derivar_consulta_producto' ||
              block['name'] == 'buscar_producto',
        );
        if (requestsProductHandoff) {
          _logger.info(
            'Product query detected; handing off to agent and turning bot off.',
          );
          return AiResponseModel(
            responseText: buildAgentHandoffMessage(tenant),
            shouldDeactivateBot: true,
          );
        }

        if (toolUseBlocks.isNotEmpty) {
          final toolResults = await Future.wait(
            toolUseBlocks.map((toolUseBlock) async {
              final toolCallId = toolUseBlock['id'] as String;
              final toolName = toolUseBlock['name'] as String;

              if (toolName == 'obtener_metodos_pago') {
                final info = await _getBusinessInfoUsecase(tenant.businessId);
                return {
                  'type': 'tool_result',
                  'tool_use_id': toolCallId,
                  'content': jsonEncode(info.paymentMethods),
                };
              } else if (toolName == 'obtener_metodos_envio') {
                final info = await _getBusinessInfoUsecase(tenant.businessId);
                final shippingResults = info.shippingZones.map((z) => {
                  'name': z.name,
                  'price': z.price,
                  'description': z.description,
                }).toList();
                return {
                  'type': 'tool_result',
                  'tool_use_id': toolCallId,
                  'content': jsonEncode(shippingResults),
                };
              }

              return {
                'type': 'tool_result',
                'tool_use_id': toolCallId,
                'content': 'Tool not found',
              };
            }),
          );

          messages
            ..add({
              'role': 'assistant',
              'content': contents,
            })
            ..add({
              'role': 'user',
              'content': toolResults,
            });

          response = await _dio.post<Map<String, dynamic>>(
            _url,
            options: Options(
              headers: {
                'x-api-key': tenant.aiApiKey,
                'anthropic-version': '2023-06-01',
                'content-type': 'application/json',
              },
            ),
            data: {
              'model': _model,
              'max_tokens': 1024,
              'cache_control': {'type': 'ephemeral'},
              'system': PromptTemplate.build(tenant),
              'tools': tools,
              'messages': messages,
            },
          );

          contents = (response.data?['content'] as List<dynamic>? ?? [])
              .cast<Map<String, dynamic>>();
        }
      }

      final textBlock = contents.firstWhere(
        (block) => block['type'] == 'text',
        orElse: () => <String, dynamic>{},
      );

      final text = textBlock.isNotEmpty ? textBlock['text'] as String : '';

      _logger.info('AI response generated: $text');
      return AiResponseModel(responseText: text);
    } on DioException catch (e) {
      _logger.severe('Failed to generate response: ${e.message}', e);
      rethrow;
    }
  }

  @override
  Future<AiResponseModel> generateSimpleResponse(
    MessageEntity message,
    TenantConfigEntity tenant,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _url,
        options: Options(
          headers: {
            'x-api-key': tenant.aiApiKey,
            'anthropic-version': '2023-06-01',
            'content-type': 'application/json',
          },
        ),
        data: {
          'model': _model,
          'max_tokens': 1024,
          'cache_control': {'type': 'ephemeral'},
          'system': PromptTemplate.build(tenant),
          'messages': [
            {
              'role': 'user',
              'content': message.content,
            },
          ],
        },
      );

      final contents = (response.data?['content'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      final content = contents.isNotEmpty ? contents[0] : <String, dynamic>{};
      final text = content.containsKey('text') ? content['text'] as String : '';

      _logger.info('AI response generated: $text');

      return AiResponseModel(responseText: text);
    } on DioException catch (e) {
      _logger.severe('Failed to generate simple response: ${e.message}', e);
      rethrow;
    }
  }
}
