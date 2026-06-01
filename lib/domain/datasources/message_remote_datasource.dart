import 'package:boty_frog/domain/entities/message_entity.dart';

/// Datasource for Message API Calls
// ignore: one_member_abstracts
abstract class MessageRemoteDatasource {
  /// Receives a message from the specified data and returns a messageId.
  Future<String> sendMessage(MessageEntity message);

  /// Sends a message to the recipient and returns the received message.
  Future<MessageEntity> receiveMessage(Map<String, dynamic> messageData);
}
