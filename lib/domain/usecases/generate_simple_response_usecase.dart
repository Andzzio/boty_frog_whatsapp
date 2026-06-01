import 'package:boty_frog/domain/entities/message_entity.dart';
import 'package:boty_frog/domain/repos/ai_response_repository.dart';

/// Use case for generating a simple AI response based on a given message.
class GenerateSimpleResponseUsecase {
  /// Constructs a [GenerateSimpleResponseUsecase] with the given repository.
  GenerateSimpleResponseUsecase(this._repository);
  final AiResponseRepository _repository;

  /// Executes the use case to generate a simple response for the given message.
  Future<MessageEntity> call(MessageEntity message) async {
    return _repository.generateSimpleResponse(message);
  }
}
