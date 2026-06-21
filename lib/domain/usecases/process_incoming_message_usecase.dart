import 'package:boty_frog/domain/entities/message_entity.dart';
import 'package:boty_frog/domain/entities/tenant_config_entity.dart';
import 'package:boty_frog/domain/usecases/add_message_in_conversation_usecase.dart';
import 'package:boty_frog/domain/usecases/generate_history_based_response.dart';
import 'package:boty_frog/domain/usecases/get_contact_usecase.dart';
import 'package:boty_frog/domain/usecases/get_or_create_conversation_usecase.dart';
import 'package:boty_frog/domain/usecases/receive_message_usecase.dart';
import 'package:boty_frog/domain/usecases/save_conversation_usecase.dart';
import 'package:boty_frog/domain/usecases/send_message_usecase.dart';
import 'package:boty_frog/domain/usecases/upload_message_media_usecase.dart';
import 'package:logging/logging.dart';

final _logger = Logger('ProcessIncomingMessageUsecase');

/// Orchestrates the process of receiving an incoming WhatsApp message,
/// running AI, saving the conversation, and sending back a response.
class ProcessIncomingMessageUsecase {
  /// Constructs a [ProcessIncomingMessageUsecase]
  /// with all required sub-usecases.
  ProcessIncomingMessageUsecase({
    required this.receiveMessage,
    required this.getContact,
    required this.getOrCreateConversation,
    required this.saveConversation,
    required this.generatedhistoryBasedResponse,
    required this.sendMessage,
    required this.addMessageInConversation,
    required this.uploadMessageMedia,
  });

  /// Usecase to parse incoming message payload.
  final ReceiveMessageUsecase receiveMessage;

  /// Usecase to extract contact data.
  final GetContactUsecase getContact;

  /// Usecase to find or create the conversation.
  final GetOrCreateConversationUsecase getOrCreateConversation;

  /// Usecase to save/persist a conversation.
  final SaveConversationUsecase saveConversation;

  /// Usecase to generate AI response based on history.
  final GenerateHistoryBasedResponse generatedhistoryBasedResponse;

  /// Usecase to send a message back.
  final SendMessageUsecase sendMessage;

  /// Usecase to add a single message in a conversation.
  final AddMessageInConversationUsecase addMessageInConversation;

  /// Usecase to upload message media (images) to storage.
  final UploadMessageMediaUsecase uploadMessageMedia;

  /// Executes the orchestrator logic for an incoming webhook message.
  Future<bool> call({
    required Map<String, dynamic> messageData,
    required List<dynamic> contactsJson,
    required TenantConfigEntity tenant,
  }) async {
    final rawMessage = await receiveMessage(messageData);
    var receivedMessage = rawMessage;

    final isMedia = rawMessage.type == MessageType.image ||
        rawMessage.type == MessageType.audio ||
        rawMessage.type == MessageType.video ||
        rawMessage.type == MessageType.file;
    if (isMedia && rawMessage.media != null) {
      try {
        final publicUrl = await uploadMessageMedia(
          mediaId: rawMessage.media!,
          apiToken: tenant.apiToken,
          businessId: tenant.businessId,
        );
        receivedMessage = rawMessage.copyWith(media: publicUrl);
      } catch (e, stackTrace) {
        _logger.warning('Failed to upload media: $e', e, stackTrace);
        receivedMessage = MessageEntity(
          id: rawMessage.id,
          recipientId: rawMessage.recipientId,
          senderId: rawMessage.senderId,
          senderName: rawMessage.senderName,
          content: rawMessage.content,
          timestamp: rawMessage.timestamp,
          isRead: rawMessage.isRead,
          type: rawMessage.type,
        );
      }
    }

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
      tenant: tenant,
    );

    if (!conversation.isBotActive) {
      await addMessageInConversation(
        conversationId: conversation.id,
        message: receivedMessage,
        tenant: tenant,
      );
      final updatedConversation = conversation.copyWith(
        messages: [...conversation.messages, receivedMessage],
        lastMessage: receivedMessage,
        unreadCount: conversation.unreadCount + 1,
      );
      await saveConversation(
        conversation: updatedConversation,
        tenant: tenant,
      );
      return true;
    }

    await addMessageInConversation(
      conversationId: conversation.id,
      message: receivedMessage,
      tenant: tenant,
    );

    conversation = conversation.copyWith(
      messages: [...conversation.messages, receivedMessage],
    );

    final botReply = await generatedhistoryBasedResponse(conversation, tenant);

    await addMessageInConversation(
      conversationId: conversation.id,
      message: botReply,
      tenant: tenant,
    );

    await sendMessage(botReply, tenant);

    final isMultimedia = receivedMessage.type == MessageType.image ||
        receivedMessage.type == MessageType.audio ||
        receivedMessage.type == MessageType.video ||
        receivedMessage.type == MessageType.file;

    conversation = conversation.copyWith(
      messages: [...conversation.messages, botReply],
      lastMessage: botReply,
      unreadCount: conversation.unreadCount + 1,
      isBotActive: !isMultimedia && conversation.isBotActive,
    );

    await saveConversation(conversation: conversation, tenant: tenant);
    return true;
  }
}
