import 'package:boty_frog/domain/usecases/add_message_in_conversation_usecase.dart';
import 'package:boty_frog/domain/usecases/generate_history_based_response.dart';
import 'package:boty_frog/domain/usecases/get_contact_usecase.dart';
import 'package:boty_frog/domain/usecases/get_or_create_conversation_usecase.dart';
import 'package:boty_frog/domain/usecases/receive_message_usecase.dart';
import 'package:boty_frog/domain/usecases/save_conversation_usecase.dart';
import 'package:boty_frog/domain/usecases/send_message_usecase.dart';
import 'package:logging/logging.dart';

final _logger = Logger('ProcessIncomingMessageUsecase');

/// Proceess
class ProcessIncomingMessageUsecase {
  /// Initialazing Usecase Orquest
  ProcessIncomingMessageUsecase({
    required this.receiveMessage,
    required this.getContact,
    required this.getOrCreateConversation,
    required this.saveConversation,
    required this.generatedhistoryBasedResponse,
    required this.sendMessage,
    required this.addMessageInConversation,
  });

  /// Returns Message Entity
  final ReceiveMessageUsecase receiveMessage;

  /// Returns Contact Entity
  final GetContactUsecase getContact;

  /// Get or Create a Conversation Entity
  final GetOrCreateConversationUsecase getOrCreateConversation;

  /// Save a Conversation Entity
  final SaveConversationUsecase saveConversation;

  /// Returns a Message Entity with AI History Based Response
  final GenerateHistoryBasedResponse generatedhistoryBasedResponse;

  /// Send Message Entity
  final SendMessageUsecase sendMessage;

  /// Add Message Entity in Conversation Entity
  final AddMessageInConversationUsecase addMessageInConversation;

  /// Call [ProcessIncomingMessageUsecase]
  Future<bool> call({
    required Map<String, dynamic> messageData,
    required List<dynamic> contactsJson,
  }) async {
    final receivedMessage = await receiveMessage(messageData);

    _logger.info(
      'Messages received: ${receivedMessage.content} '
      'from ${receivedMessage.senderName}',
    );

    final contact = await getContact(contactsJson);

    if (contact == null) {
      _logger.warning('No contact found in webhook payload, ignoring...');
      return false;
    }

    var conversation = await getOrCreateConversation(
      contact: contact,
    );

    await addMessageInConversation(
      conversationId: conversation.id,
      message: receivedMessage,
    );

    conversation = conversation.copyWith(
      messages: [...conversation.messages, receivedMessage],
    );

    final botReply = await generatedhistoryBasedResponse(conversation);

    await addMessageInConversation(
      conversationId: conversation.id,
      message: botReply,
    );

    conversation = conversation.copyWith(
      messages: [...conversation.messages, botReply],
      lastMessage: botReply,
      unreadCount: conversation.unreadCount + 1,
    );

    await saveConversation(conversation: conversation);

    await sendMessage(botReply);
    return true;
  }
}
