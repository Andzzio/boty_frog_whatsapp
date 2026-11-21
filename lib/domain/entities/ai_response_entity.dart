/// Entity representing an AI response, containing the response text.
class AiResponseEntity {
  /// Constructs an [AiResponseEntity] with the given response text.
  AiResponseEntity({
    required this.responseText,
    this.shouldDeactivateBot = false,
  });

  /// The text of the AI response.
  final String responseText;

  /// Indicates whether the bot should be turned off after sending this reply.
  final bool shouldDeactivateBot;
}
