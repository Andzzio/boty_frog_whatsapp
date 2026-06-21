import 'package:boty_frog/data/models/ai_response_model.dart';
import 'package:boty_frog/domain/entities/conversation_entity.dart';
import 'package:boty_frog/domain/entities/message_entity.dart';
import 'package:boty_frog/domain/entities/tenant_config_entity.dart';

/// Remote datasource interface to generate AI response texts.
abstract class AiResponseRemoteDatasource {
  /// Generates a simple AI response for a single message.
  Future<AiResponseModel> generateSimpleResponse(
    MessageEntity message,
    TenantConfigEntity tenant,
  );

  /// Generates an AI response based on the conversation history.
  Future<AiResponseModel> generateHistoryBasedResponse(
    ConversationEntity conversation,
    TenantConfigEntity tenant,
  );
}
