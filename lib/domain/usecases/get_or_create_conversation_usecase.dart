import 'package:boty_frog/domain/entities/contact_entity.dart';
import 'package:boty_frog/domain/entities/conversation_entity.dart';
import 'package:boty_frog/domain/entities/tenant_config_entity.dart';
import 'package:boty_frog/domain/repos/conversation_repository.dart';

/// Usecase to fetch an existing conversation or initialize a new one.
class GetOrCreateConversationUsecase {
  /// Constructs a [GetOrCreateConversationUsecase]
  /// with the given [ConversationRepository].
  GetOrCreateConversationUsecase(this._repo);
  final ConversationRepository _repo;

  /// Invokes the usecase to obtain or create a conversation for a contact.
  Future<ConversationEntity> call({
    required ContactEntity contact,
    required TenantConfigEntity tenant,
  }) async {
    final conversation = await _repo.getConversation(
      contact: contact,
      tenant: tenant,
    );
    if (conversation != null) return conversation;
    final newConversation = ConversationEntity(
      contact: contact,
      id: contact.phoneId,
      unreadCount: 0,
    );

    await _repo.saveConversation(
      conversation: newConversation,
      tenant: tenant,
    );

    return newConversation;
  }
}
