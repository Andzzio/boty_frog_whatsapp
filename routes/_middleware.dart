import 'dart:io';

import 'package:boty_frog/core/logger.dart';
import 'package:boty_frog/data/datasources/ai_response_claude_datasource.dart';
import 'package:boty_frog/data/datasources/contact_whatsapp_api_datasource.dart';
import 'package:boty_frog/data/datasources/conversation_in_memory_datasource.dart';
import 'package:boty_frog/data/datasources/message_whatsapp_api_datasource.dart';
import 'package:boty_frog/data/repos/ai_response_repository_impl.dart';
import 'package:boty_frog/data/repos/contact_repository_impl.dart';
import 'package:boty_frog/data/repos/conversation_repository_impl.dart';
import 'package:boty_frog/data/repos/message_repository_impl.dart';
import 'package:boty_frog/domain/usecases/add_message_in_conversation_usecase.dart';
import 'package:boty_frog/domain/usecases/generate_history_based_response.dart';
import 'package:boty_frog/domain/usecases/get_contact_usecase.dart';
import 'package:boty_frog/domain/usecases/get_or_create_conversation_usecase.dart';
import 'package:boty_frog/domain/usecases/process_incoming_message_usecase.dart';
import 'package:boty_frog/domain/usecases/receive_message_usecase.dart';
import 'package:boty_frog/domain/usecases/save_conversation_usecase.dart';
import 'package:boty_frog/domain/usecases/send_message_usecase.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dio/dio.dart';
import 'package:dotenv/dotenv.dart';
import 'package:firebase_admin_sdk/firebase_admin_sdk.dart';

Handler middleware(Handler handler) {
  initLogger();

  final env = DotEnv()..load();

  const requiredVars = [
    'API_KEY',
    'WHATSAPP_PHONE_ID',
    'WHATSAPP_API_TOKEN',
    'VERIFY_TOKEN',
    'GOOGLE_APPLICATION_CREDENTIALS',
    'PROJECT_ID',
  ];

  for (final key in requiredVars) {
    if ((env[key] ?? '').isEmpty) {
      throw StateError('Variable de entorno requerida no configurada: $key');
    }
  }
  final app = FirebaseApp.initializeApp(
    options: AppOptions(
      credential: Credential.fromServiceAccount(
        File(env['GOOGLE_APPLICATION_CREDENTIALS']!),
      ),
      projectId: env['PROJECT_ID'],
    ),
  );
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
        provider<ProcessIncomingMessageUsecase>(
          (context) => ProcessIncomingMessageUsecase(
            receiveMessage: ReceiveMessageUsecase(
              messageRepository: messageRepositoryImpl,
            ),
            getContact: GetContactUsecase(contactRepositoryImpl),
            getOrCreateConversation: GetOrCreateConversationUsecase(
              conversationRepositoryImpl,
            ),
            saveConversation: SaveConversationUsecase(
              conversationRepositoryImpl,
            ),
            generatedhistoryBasedResponse: GenerateHistoryBasedResponse(
              aiResponseRepositoryImpl,
            ),
            sendMessage: SendMessageUsecase(
              messageRepository: messageRepositoryImpl,
            ),
            addMessageInConversation: AddMessageInConversationUsecase(
              conversationRepositoryImpl,
            ),
          ),
        ),
      );
}
