import 'package:boty_frog/domain/entities/message_entity.dart';
import 'package:boty_frog/domain/repos/conversation_repository.dart';

/// Adds a [MessageEntity] to a conversation.
class AddMessageInConversationUsecase {
  /// Constructor for [AddMessageInConversationUsecase]
  AddMessageInConversationUsecase(this._repo);

  final ConversationRepository _repo;

  /// Call of [AddMessageInConversationUsecase].
  Future<void> call({
    required String conversationId,
    required MessageEntity message,
  }) async {
    await _repo.addMessageInConversation(
      conversationId: conversationId,
      message: message,
    );
  }
}
