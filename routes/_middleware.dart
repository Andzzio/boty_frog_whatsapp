import 'package:boty_frog/core/logger.dart';
import 'package:boty_frog/data/datasources/ai_response_claude_datasource.dart';
import 'package:boty_frog/data/datasources/contact_whatsapp_api_datasource.dart';
import 'package:boty_frog/data/datasources/conversation_in_memory_datasource.dart';
import 'package:boty_frog/data/datasources/message_whatsapp_api_datasource.dart';
import 'package:boty_frog/data/repos/ai_response_repository_impl.dart';
import 'package:boty_frog/data/repos/contact_repository_impl.dart';
import 'package:boty_frog/data/repos/conversation_repository_impl.dart';
import 'package:boty_frog/data/repos/message_repository_impl.dart';
import 'package:boty_frog/domain/usecases/generate_history_based_response.dart';
import 'package:boty_frog/domain/usecases/generate_simple_response_usecase.dart';
import 'package:boty_frog/domain/usecases/get_contact_usecase.dart';
import 'package:boty_frog/domain/usecases/get_or_create_conversation_usecase.dart';
import 'package:boty_frog/domain/usecases/receive_message_usecase.dart';
import 'package:boty_frog/domain/usecases/save_conversation_usecase.dart';
import 'package:boty_frog/domain/usecases/send_message_usecase.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dio/dio.dart';
import 'package:dotenv/dotenv.dart';

Handler middleware(Handler handler) {
  initLogger();
  final env = DotEnv()..load();

  const requiredVars = [
    'API_KEY',
    'WHATSAPP_PHONE_ID',
    'WHATSAPP_API_TOKEN',
    'VERIFY_TOKEN',
  ];

  for (final key in requiredVars) {
    if ((env[key] ?? '').isEmpty) {
      throw StateError('Variable de entorno requerida no configurada: $key');
    }
  }

  final dio = Dio();
  final messageWhatsappApiDatasource = MessageWhatsappApiDatasource(
    dio: dio,
    env: env,
  );
  final messageRepositoryImpl = MessageRepositoryImpl(
    remoteDatasource: messageWhatsappApiDatasource,
  );
  final aiResponseClaudeDatasource = AiResponseClaudeDatasource(
    dio: dio,
    env: env,
  );
  final aiResponseRepositoryImpl = AiResponseRepositoryImpl(
    aiResponseClaudeDatasource,
    env,
  );
  final conversationInMemoryDatasource = ConversationInMemoryDatasource();
  final conversationRepositoryImpl = ConversationRepositoryImpl(
    conversationInMemoryDatasource,
  );

  final contactWhatsappApiDatasource = ContactWhatsappApiDatasource();
  final contactRepositoryImpl = ContactRepositoryImpl(
    contactWhatsappApiDatasource,
  );

  return handler
      .use(
        provider<DotEnv>(
          (context) => env,
        ),
      )
      .use(
        provider<SendMessageUsecase>(
          (context) =>
              SendMessageUsecase(messageRepository: messageRepositoryImpl),
        ),
      )
      .use(
        provider<ReceiveMessageUsecase>(
          (context) =>
              ReceiveMessageUsecase(messageRepository: messageRepositoryImpl),
        ),
      )
      .use(
        provider<GenerateSimpleResponseUsecase>(
          (context) => GenerateSimpleResponseUsecase(aiResponseRepositoryImpl),
        ),
      )
      .use(
        provider<GetOrCreateConversationUsecase>(
          (context) =>
              GetOrCreateConversationUsecase(conversationRepositoryImpl),
        ),
      )
      .use(
        provider<SaveConversationUsecase>(
          (context) => SaveConversationUsecase(conversationRepositoryImpl),
        ),
      )
      .use(
        provider<GetContactUsecase>(
          (context) => GetContactUsecase(contactRepositoryImpl),
        ),
      )
      .use(
        provider<GenerateHistoryBasedResponse>(
          (context) => GenerateHistoryBasedResponse(aiResponseRepositoryImpl),
        ),
      );
}
