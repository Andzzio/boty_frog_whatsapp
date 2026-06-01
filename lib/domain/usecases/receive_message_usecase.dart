import 'package:boty_frog/domain/entities/message_entity.dart';
import 'package:boty_frog/domain/repos/message_repository.dart';

/// This file defines the [ReceiveMessageUsecase] class, which is responsible
/// for handling the logic for receiving messages in the application.
/// It serves as an intermediary between the presentation layer and
/// the data layer, ensuring that the necessary data is passed to the
///  appropriate datasource for receiving messages.
class ReceiveMessageUsecase {
  /// Constructs a [ReceiveMessageUsecase] with the given [MessageRepository].
  ReceiveMessageUsecase({required MessageRepository messageRepository})
    : _messageRepository = messageRepository;

  final MessageRepository _messageRepository;

  /// Receives a message using the [MessageRepository].
  Future<MessageEntity> call(Map<String, dynamic> messageData) async {
    return _messageRepository.receiveMessage(messageData);
  }
}
