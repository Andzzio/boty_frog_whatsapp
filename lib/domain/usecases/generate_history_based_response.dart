import 'package:boty_frog/domain/entities/conversation_entity.dart';
import 'package:boty_frog/domain/entities/message_entity.dart';
import 'package:boty_frog/domain/entities/tenant_config_entity.dart';
import 'package:boty_frog/domain/repos/ai_response_repository.dart';

/// Usecase to generate an AI reply based on a conversation history.
class GenerateHistoryBasedResponse {
  /// Constructs a [GenerateHistoryBasedResponse]
  /// with the given [AiResponseRepository].
  GenerateHistoryBasedResponse(this._repo);
  final AiResponseRepository _repo;

  /// Invokes the usecase to obtain the AI response for a conversation.
  Future<MessageEntity> call(
    ConversationEntity conversation,
    TenantConfigEntity tenant,
  ) async {
    return _repo.generateHistoryBasedResponse(conversation, tenant);
  }
}
