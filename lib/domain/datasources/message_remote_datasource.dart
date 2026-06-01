/// Datasource for Message API Calls
// ignore: one_member_abstracts
abstract class MessageRemoteDatasource {
  /// Sends a message to the specified recipient.
  void sendMessage(String message, String recipientId);
}
