import 'package:boty_frog/domain/entities/message_entity.dart';
import 'package:boty_frog/domain/repos/message_repository.dart';

/// This file defines the [SendMessageUsecase] class, which is responsible for
/// handling the logic for sending messages in the application. It serves as an
/// intermediary between the presentation layer and the data layer, ensuring
/// that the necessary data is passed to the appropriate datasource for
///  sending messages.
class SendMessageUsecase {
  /// Constructs a [SendMessageUsecase] with the given [MessageRepository].
  SendMessageUsecase({required MessageRepository messageRepository})
    : _messageRepository = messageRepository;

  final MessageRepository _messageRepository;

  /// Sends a message using the [MessageRepository].
  Future<String> call(MessageEntity message) async {
    return _messageRepository.sendMessage(message);
  }
}
