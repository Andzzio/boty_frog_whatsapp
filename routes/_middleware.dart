import 'dart:io';

import 'package:boty_frog/core/business_registry.dart';
import 'package:boty_frog/core/logger.dart';
import 'package:boty_frog/data/datasources/ai_response_claude_datasource.dart';
import 'package:boty_frog/data/datasources/business_info_firestore_datasource.dart';
import 'package:boty_frog/data/datasources/contact_whatsapp_api_datasource.dart';
import 'package:boty_frog/data/datasources/conversation_firestore_datasource.dart';
import 'package:boty_frog/data/datasources/message_whatsapp_api_datasource.dart';
import 'package:boty_frog/data/datasources/product_firestore_datasource.dart';
import 'package:boty_frog/data/datasources/tenant_config_firestore_datasource.dart';
import 'package:boty_frog/data/repos/ai_response_repository_impl.dart';
import 'package:boty_frog/data/repos/business_info_repository_impl.dart';
import 'package:boty_frog/data/repos/contact_repository_impl.dart';
import 'package:boty_frog/data/repos/conversation_repository_impl.dart';
import 'package:boty_frog/data/repos/message_repository_impl.dart';
import 'package:boty_frog/data/repos/product_repository_impl.dart';
import 'package:boty_frog/data/repos/tenant_config_repository_impl.dart';
import 'package:boty_frog/domain/repos/conversation_repository.dart';
import 'package:boty_frog/domain/repos/tenant_config_repository.dart';
import 'package:boty_frog/domain/usecases/add_message_in_conversation_usecase.dart';
import 'package:boty_frog/domain/usecases/generate_history_based_response.dart';
import 'package:boty_frog/domain/usecases/get_business_info_usecase.dart';
import 'package:boty_frog/domain/usecases/get_contact_usecase.dart';
import 'package:boty_frog/domain/usecases/get_or_create_conversation_usecase.dart';
import 'package:boty_frog/domain/usecases/process_incoming_message_usecase.dart';
import 'package:boty_frog/domain/usecases/receive_message_usecase.dart';
import 'package:boty_frog/domain/usecases/save_conversation_usecase.dart';
import 'package:boty_frog/domain/usecases/search_products_usecase.dart';
import 'package:boty_frog/domain/usecases/send_message_usecase.dart';
import 'package:boty_frog/domain/usecases/upload_message_media_usecase.dart';
import 'package:dart_frog/dart_frog.dart' hide Response;
import 'package:dart_frog/dart_frog.dart' as frog show Response;
import 'package:dio/dio.dart';
import 'package:dotenv/dotenv.dart';
import 'package:firebase_admin_sdk/firebase_admin_sdk.dart';

bool _isInitialized = false;
final _businessRegistry = BusinessRegistry();

Future<void> _bootstrap(TenantConfigRepository repository) async {
  try {
    final configs = await repository.loadAllConfigs();
    _businessRegistry.registerAll(configs);
    _isInitialized = true;
  } catch (e) {
    rethrow;
  }
}

Handler middleware(Handler handler) {
  initLogger();

  final env = DotEnv()..load();

  final credential = env['GOOGLE_APPLICATION_CREDENTIALS'] != null
      ? Credential.fromServiceAccount(
          File(env['GOOGLE_APPLICATION_CREDENTIALS']!),
        )
      : Credential.fromApplicationDefaultCredentials();

  final projectId = env['PROJECT_ID'] ?? Platform.environment['PROJECT_ID'];

  final app = FirebaseApp.initializeApp(
    options: AppOptions(
      credential: credential,
      projectId: projectId,
      storageBucket: 'catalogo-virtual-app.firebasestorage.app',
    ),
  );

  final dio = Dio();
  final messageWhatsappApiDatasource = MessageWhatsappApiDatasource(dio: dio);
  final messageRepositoryImpl = MessageRepositoryImpl(
    remoteDatasource: messageWhatsappApiDatasource,
  );
  final productFirestoreDatasource = ProductFirestoreDatasource(app);
  final productRepositoryImpl = ProductRepositoryImpl(
    productFirestoreDatasource,
  );
  final searchProductsUsecase = SearchProductsUsecase(productRepositoryImpl);

  final businessInfoFirestoreDatasource = BusinessInfoFirestoreDatasource(app);
  final businessInfoRepositoryImpl = BusinessInfoRepositoryImpl(
    businessInfoFirestoreDatasource,
  );
  final getBusinessInfoUsecase = GetBusinessInfoUsecase(
    businessInfoRepositoryImpl,
  );

  final aiResponseClaudeDatasource = AiResponseClaudeDatasource(
    dio: dio,
    searchProductsUsecase: searchProductsUsecase,
    getBusinessInfoUsecase: getBusinessInfoUsecase,
  );
  final aiResponseRepositoryImpl = AiResponseRepositoryImpl(
    aiResponseClaudeDatasource,
  );
  final conversationFirestoreDatasource = ConversationFirestoreDatasource(app);
  final conversationRepositoryImpl = ConversationRepositoryImpl(
    conversationFirestoreDatasource,
  );

  final contactWhatsappApiDatasource = ContactWhatsappApiDatasource();
  final contactRepositoryImpl = ContactRepositoryImpl(
    contactWhatsappApiDatasource,
  );

  final tenantConfigDatasource = TenantConfigFirestoreDatasource(app);
  final tenantConfigRepository = TenantConfigRepositoryImpl(
    tenantConfigDatasource,
  );

  final sendMessageUsecase = SendMessageUsecase(
    messageRepository: messageRepositoryImpl,
  );

  final getOrCreateConversation = GetOrCreateConversationUsecase(
    conversationRepositoryImpl,
  );

  final generateHistoryBasedResponse = GenerateHistoryBasedResponse(
    aiResponseRepositoryImpl,
  );

  final processIncomingMessageUsecase = ProcessIncomingMessageUsecase(
    receiveMessage: ReceiveMessageUsecase(
      messageRepository: messageRepositoryImpl,
    ),
    getContact: GetContactUsecase(contactRepositoryImpl),
    getOrCreateConversation: getOrCreateConversation,
    saveConversation: SaveConversationUsecase(
      conversationRepositoryImpl,
    ),
    generatedhistoryBasedResponse: generateHistoryBasedResponse,
    sendMessage: sendMessageUsecase,
    addMessageInConversation: AddMessageInConversationUsecase(
      conversationRepositoryImpl,
    ),
    uploadMessageMedia: UploadMessageMediaUsecase(
      firebaseApp: app,
      dio: dio,
    ),
  );

  final pipeline = handler
      .use(
        provider<BusinessRegistry>(
          (context) => _businessRegistry,
        ),
      )
      .use(
        provider<TenantConfigRepository>(
          (context) => tenantConfigRepository,
        ),
      )
      .use(
        provider<SendMessageUsecase>(
          (context) => sendMessageUsecase,
        ),
      )
      .use(
        provider<GetOrCreateConversationUsecase>(
          (context) => getOrCreateConversation,
        ),
      )
      .use(
        provider<GenerateHistoryBasedResponse>(
          (context) => generateHistoryBasedResponse,
        ),
      )
      .use(
        provider<ProcessIncomingMessageUsecase>(
          (context) => processIncomingMessageUsecase,
        ),
      )
      .use(
        provider<ConversationRepository>(
          (context) => conversationRepositoryImpl,
        ),
      );

  return (context) async {
    if (!_isInitialized) {
      await _bootstrap(tenantConfigRepository);
    }

    if (context.request.method == HttpMethod.options) {
      return frog.Response(
        statusCode: 204,
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
          'Access-Control-Allow-Headers':
              'Content-Type, Authorization, ngrok-skip-browser-warning',
        },
      );
    }

    final response = await pipeline(context);

    return response.copyWith(
      headers: {
        ...response.headers,
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers':
            'Content-Type, Authorization, ngrok-skip-browser-warning',
      },
    );
  };
}
