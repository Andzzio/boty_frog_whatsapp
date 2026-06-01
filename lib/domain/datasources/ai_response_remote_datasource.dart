import 'package:boty_frog/data/models/ai_response_model.dart';
import 'package:boty_frog/domain/entities/message_entity.dart';

/// Datasource for AI Response API Calls
abstract class AiResponseRemoteDatasource {
  /// Generates a simple response based on the given message
  /// and returns the AI response Model.
  Future<AiResponseModel> generateSimpleResponse(MessageEntity message);

  /// Generates a response based on the given message history
  /// and returns the AI response Model.
  Future<AiResponseModel> generateHistoryBasedResponse(
    List<MessageEntity> messageHistory,
  );
}
