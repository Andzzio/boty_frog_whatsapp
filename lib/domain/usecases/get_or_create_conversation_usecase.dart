import 'package:boty_frog/domain/entities/contact_entity.dart';
import 'package:boty_frog/domain/entities/conversation_entity.dart';
import 'package:boty_frog/domain/repos/conversation_repository.dart';

/// Returns or create a [ConversationEntity] by phoneId
class GetOrCreateConversationUsecase {
  /// Constructor for [GetOrCreateConversationUsecase]
  GetOrCreateConversationUsecase(this._repo);

  final ConversationRepository _repo;

  /// Call of [GetOrCreateConversationUsecase]
  Future<ConversationEntity> call({required ContactEntity contact}) async {
    final conversation = await _repo.getConversation(contact: contact);
    if (conversation != null) return conversation;
    final newConversation = ConversationEntity(
      contact: contact,
    );

    await _repo.saveConversation(conversation: newConversation);

    return newConversation;
  }
}
