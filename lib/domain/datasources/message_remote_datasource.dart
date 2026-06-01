import 'package:boty_frog/domain/entities/message_entity.dart';

/// Datasource for Message API Calls
// ignore: one_member_abstracts
abstract class MessageRemoteDatasource {
  /// Sends a message to the specified recipient.
  void sendMessage(MessageEntity message);

  /// Receives a message from the specified data.
  void receiveMessage(Map<String, dynamic> messageData);
}
