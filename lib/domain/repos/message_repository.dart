import 'package:boty_frog/domain/entities/message_entity.dart';

/// Repository for managing message data.
abstract class MessageRepository {
  /// Sends a message to the recipient and returns the message Entity.
  Future<MessageEntity> sendMessage(MessageEntity message);

  /// Receives a message from the specified data and returns the message Entity.
  Future<MessageEntity> receiveMessage(Map<String, dynamic> messageData);
}
