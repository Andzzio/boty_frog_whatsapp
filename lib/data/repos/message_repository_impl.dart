import 'package:boty_frog/domain/datasources/message_remote_datasource.dart';
import 'package:boty_frog/domain/entities/message_entity.dart';
import 'package:boty_frog/domain/entities/tenant_config_entity.dart';
import 'package:boty_frog/domain/repos/message_repository.dart';

/// Implementation of [MessageRepository]
/// delegating to [MessageRemoteDatasource].
class MessageRepositoryImpl implements MessageRepository {
  /// Constructs a [MessageRepositoryImpl]
  /// with the given [remoteDatasource].
  MessageRepositoryImpl({
    required MessageRemoteDatasource remoteDatasource,
  }) : _remoteDatasource = remoteDatasource;

  final MessageRemoteDatasource _remoteDatasource;

  @override
  Future<MessageEntity> receiveMessage(
    Map<String, dynamic> messageData,
  ) async {
    return _remoteDatasource.receiveMessage(messageData);
  }

  @override
  Future<MessageEntity> sendMessage(
    MessageEntity message,
    TenantConfigEntity tenant,
  ) async {
    return _remoteDatasource.sendMessage(message, tenant);
  }
}
