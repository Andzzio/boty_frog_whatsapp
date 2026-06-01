import 'package:boty_frog/core/logger.dart';
import 'package:boty_frog/data/datasources/message_whatsapp_api_datasource.dart';
import 'package:boty_frog/data/repos/message_repository_impl.dart';
import 'package:boty_frog/domain/usecases/receive_message_usecase.dart';
import 'package:boty_frog/domain/usecases/send_message_usecase.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dio/dio.dart';
import 'package:dotenv/dotenv.dart';

Handler middleware(Handler handler) {
  initLogger();
  final env = DotEnv()..load();
  final messageWhatsappApiDatasource = MessageWhatsappApiDatasource(
    dio: Dio(),
    env: env,
  );
  final messageRepositoryImpl = MessageRepositoryImpl(
    remoteDatasource: messageWhatsappApiDatasource,
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
      );
}
