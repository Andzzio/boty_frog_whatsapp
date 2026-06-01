import 'package:boty_frog/domain/entities/ai_response_entity.dart';
import 'package:boty_frog/domain/entities/message_entity.dart';

/// Model representing an AI response, extending the [AiResponseEntity].
class AiResponseModel extends AiResponseEntity {
  /// Constructs an [AiResponseModel] with the given response text.
  AiResponseModel({required super.responseText});

  /// Converts the [AiResponseModel] to a [MessageEntity] for use
  /// in the application.
  MessageEntity toMessageEntity({
    required String recipientId,
    required String senderId,
  }) {
    return MessageEntity(
      recipientId: recipientId,
      content: responseText,
      senderName: 'Boty Frog',
      timestamp: DateTime.now(),
      senderId: senderId,
    );
  }
}
