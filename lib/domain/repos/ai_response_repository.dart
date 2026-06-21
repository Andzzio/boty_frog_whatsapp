import 'package:boty_frog/domain/entities/conversation_entity.dart';
import 'package:boty_frog/domain/entities/message_entity.dart';
import 'package:boty_frog/domain/entities/tenant_config_entity.dart';

/// Repository interface to generate AI messages.
abstract class AiResponseRepository {
  /// Generates a simple AI response for a single message.
  Future<MessageEntity> generateSimpleResponse(
    MessageEntity message,
    TenantConfigEntity tenant,
  );

  /// Generates an AI response based on the conversation history.
  Future<MessageEntity> generateHistoryBasedResponse(
    ConversationEntity conversation,
    TenantConfigEntity tenant,
  );
}
