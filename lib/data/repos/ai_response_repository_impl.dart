import 'package:boty_frog/domain/datasources/ai_response_remote_datasource.dart';
import 'package:boty_frog/domain/entities/conversation_entity.dart';
import 'package:boty_frog/domain/entities/message_entity.dart';
import 'package:boty_frog/domain/entities/tenant_config_entity.dart';
import 'package:boty_frog/domain/repos/ai_response_repository.dart';

/// Implementation of [AiResponseRepository]
/// delegating to [AiResponseRemoteDatasource].
class AiResponseRepositoryImpl implements AiResponseRepository {
  /// Constructs an [AiResponseRepositoryImpl]
  /// with the given [_dataSource].
  AiResponseRepositoryImpl(this._dataSource);

  final AiResponseRemoteDatasource _dataSource;

  @override
  Future<MessageEntity> generateHistoryBasedResponse(
    ConversationEntity conversation,
    TenantConfigEntity tenant,
  ) async {
    final aiResponseModel = await _dataSource.generateHistoryBasedResponse(
      conversation,
      tenant,
    );
    final messageEntity = aiResponseModel.toMessageEntity(
      recipientId: conversation.contact.phoneId,
      senderId: tenant.phoneId,
      tenant: tenant,
    );
    return messageEntity;
  }

  @override
  Future<MessageEntity> generateSimpleResponse(
    MessageEntity message,
    TenantConfigEntity tenant,
  ) async {
    final aiResponseModel = await _dataSource.generateSimpleResponse(
      message,
      tenant,
    );
    final messageEntity = aiResponseModel.toMessageEntity(
      recipientId: message.senderId,
      senderId: tenant.phoneId,
      tenant: tenant,
    );

    return messageEntity;
  }
}
