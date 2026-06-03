import 'package:boty_frog/domain/entities/conversation_entity.dart';
import 'package:boty_frog/domain/entities/message_entity.dart';
import 'package:boty_frog/domain/repos/ai_response_repository.dart';

/// Generate a Response History Based
class GenerateHistoryBasedResponse {
  /// Constructor for [GenerateHistoryBasedResponse]
  GenerateHistoryBasedResponse(this._repo);

  final AiResponseRepository _repo;

  /// Executes the use case to generate a history based response
  /// for the given conversation.
  Future<MessageEntity> call(ConversationEntity conversation) async {
    return _repo.generateHistoryBasedResponse(conversation);
  }
}
