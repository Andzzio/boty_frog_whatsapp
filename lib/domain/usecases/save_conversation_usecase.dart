import 'package:boty_frog/domain/entities/conversation_entity.dart';
import 'package:boty_frog/domain/repos/conversation_repository.dart';

/// Saves a [ConversationEntity].
class SaveConversationUsecase {
  /// Constructor for [SaveConversationUsecase]
  SaveConversationUsecase(this._repo);

  final ConversationRepository _repo;

  /// Call of [SaveConversationUsecase].
  Future<void> call({required ConversationEntity conversation}) async {
    await _repo.saveConversation(conversation: conversation);
  }
}
