import 'package:boty_frog/domain/entities/message_entity.dart';

/// Repository for managing message data.
// ignore: one_member_abstracts
abstract class MessageRepository {
  /// Sends a message to the specified recipient.
  Future<String> sendMessage(MessageEntity message);

  /// Receives a message from the specified data.
  Future<MessageEntity> receiveMessage(Map<String, dynamic> messageData);
}
