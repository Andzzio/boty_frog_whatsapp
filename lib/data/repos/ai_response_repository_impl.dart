import 'package:boty_frog/domain/datasources/ai_response_remote_datasource.dart';
import 'package:boty_frog/domain/entities/message_entity.dart';
import 'package:boty_frog/domain/repos/ai_response_repository.dart';
import 'package:dotenv/dotenv.dart';

/// Datasource for AI Response API Calls using Claude API
class AiResponseRepositoryImpl implements AiResponseRepository {
  /// Constructs a [AiResponseRepositoryImpl] with the given data source.
  AiResponseRepositoryImpl(this._dataSource, this._env);

  final DotEnv _env;
  final AiResponseRemoteDatasource _dataSource;

  @override
  Future<MessageEntity> generateHistoryBasedResponse(
    List<MessageEntity> messageHistory,
  ) async {
    final aiResponseModel = await _dataSource.generateHistoryBasedResponse(
      messageHistory,
    );
    final messageEntity = aiResponseModel.toMessageEntity(
      recipientId: messageHistory.last.senderId,
      senderId: _env['WHATSAPP_PHONE_ID'] ?? 'id-notfound',
    );
    return messageEntity;
  }

  @override
  Future<MessageEntity> generateSimpleResponse(MessageEntity message) async {
    final aiResponseModel = await _dataSource.generateSimpleResponse(message);
    final messageEntity = aiResponseModel.toMessageEntity(
      recipientId: message.senderId,
      senderId: _env['WHATSAPP_PHONE_ID'] ?? 'id-notfound',
    );

    return messageEntity;
  }
}
