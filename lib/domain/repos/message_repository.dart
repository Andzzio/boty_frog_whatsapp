/// Repository for managing message data.
// ignore: one_member_abstracts
abstract class MessageRepository {
  /// Sends a message to the specified recipient.
  void sendMessage(String message, String recipientId);

  /// Receives a message from the specified data.
  void receiveMessage(Map<String, dynamic> messageData);
}
