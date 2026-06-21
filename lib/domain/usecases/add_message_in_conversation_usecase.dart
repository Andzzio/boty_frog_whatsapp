import 'package:boty_frog/domain/entities/message_entity.dart';
import 'package:boty_frog/domain/entities/tenant_config_entity.dart';
import 'package:boty_frog/domain/repos/conversation_repository.dart';

/// Usecase to append a message to a conversation.
class AddMessageInConversationUsecase {
  /// Constructs an [AddMessageInConversationUsecase]
  /// with the given [ConversationRepository].
  AddMessageInConversationUsecase(this._repo);
  final ConversationRepository _repo;

  /// Invokes the usecase to add a message to a specific conversation.
  Future<void> call({
    required String conversationId,
    required MessageEntity message,
    required TenantConfigEntity tenant,
  }) async {
    await _repo.addMessageInConversation(
      conversationId: conversationId,
      message: message,
      tenant: tenant,
    );
  }
}
