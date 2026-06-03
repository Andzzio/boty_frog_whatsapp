import 'package:boty_frog/domain/entities/conversation_entity.dart';
import 'package:boty_frog/domain/entities/message_entity.dart';

/// Datasource for AI Response API Calls
abstract class AiResponseRepository {
  /// Generates a simple response based on the given message
  /// and returns the message Entity.
  Future<MessageEntity> generateSimpleResponse(MessageEntity message);

  /// Generates a response based on the given message history
  /// and returns the message Entity.
  Future<MessageEntity> generateHistoryBasedResponse(
    ConversationEntity conversation,
  );
}
