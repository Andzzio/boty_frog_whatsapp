import 'package:boty_frog/domain/datasources/message_remote_datasource.dart';
import 'package:boty_frog/domain/entities/message_entity.dart';
import 'package:boty_frog/domain/repos/message_repository.dart';

/// Implementation of the [MessageRepository] interface.
class MessageRepositoryImpl implements MessageRepository {
  /// Constructs a [MessageRepositoryImpl].
  MessageRepositoryImpl({required MessageRemoteDatasource remoteDatasource})
    : _remoteDatasource = remoteDatasource;

  /// The remote datasource for message API calls.
  final MessageRemoteDatasource _remoteDatasource;

  @override
  Future<MessageEntity> receiveMessage(
    Map<String, dynamic> messageData,
  ) async {
    return _remoteDatasource.receiveMessage(messageData);
  }

  @override
  Future<String> sendMessage(MessageEntity message) async {
    return _remoteDatasource.sendMessage(message);
  }
}
