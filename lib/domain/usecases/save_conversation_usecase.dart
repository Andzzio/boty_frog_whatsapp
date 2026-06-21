import 'package:boty_frog/domain/entities/conversation_entity.dart';
import 'package:boty_frog/domain/entities/tenant_config_entity.dart';
import 'package:boty_frog/domain/repos/conversation_repository.dart';

/// Usecase to save or update conversation state.
class SaveConversationUsecase {
  /// Constructs a [SaveConversationUsecase]
  /// with the given [ConversationRepository].
  SaveConversationUsecase(this._repo);
  final ConversationRepository _repo;

  /// Invokes the usecase to persist the conversation.
  Future<void> call({
    required ConversationEntity conversation,
    required TenantConfigEntity tenant,
  }) async {
    await _repo.saveConversation(
      conversation: conversation,
      tenant: tenant,
    );
  }
}
