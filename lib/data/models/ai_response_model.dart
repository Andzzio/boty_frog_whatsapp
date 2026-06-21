import 'package:boty_frog/domain/entities/ai_response_entity.dart';
import 'package:boty_frog/domain/entities/message_entity.dart';
import 'package:boty_frog/domain/entities/tenant_config_entity.dart';

/// Model representing the raw AI response text, extending [AiResponseEntity].
class AiResponseModel extends AiResponseEntity {
  /// Constructs an [AiResponseModel] instance.
  AiResponseModel({required super.responseText});

  /// Map this model to a [MessageEntity] to be processed by usecases.
  MessageEntity toMessageEntity({
    required String recipientId,
    required String senderId,
    required TenantConfigEntity tenant,
  }) {
    return MessageEntity(
      recipientId: recipientId,
      content: responseText,
      senderName: tenant.botName,
      timestamp: DateTime.now(),
      senderId: senderId,
    );
  }
}
