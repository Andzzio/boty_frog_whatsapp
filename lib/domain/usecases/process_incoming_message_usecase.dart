import 'dart:async';

import 'package:boty_frog/core/debounce_manager.dart';
import 'package:boty_frog/domain/entities/contact_entity.dart';
import 'package:boty_frog/domain/entities/conversation_entity.dart';
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
import 'package:boty_frog/domain/utils/handoff_message.dart';
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
    this.debounceDuration = const Duration(seconds: 3),
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

  /// The duration to debounce processing.
  final Duration debounceDuration;

  /// Per-conversation tail of the processing queue. It guarantees that two
  /// webhooks of the same customer are evaluated one after the other, so the
  /// second one always sees the bot state persisted by the first one.
  final Map<String, Completer<void>> _locks = <String, Completer<void>>{};

  /// Executes the orchestrator logic for an incoming webhook message.
  Future<bool> call({
    required Map<String, dynamic> messageData,
    required List<dynamic> contactsJson,
    required TenantConfigEntity tenant,
  }) async {
    final rawMessage = await receiveMessage(messageData);
    var receivedMessage = rawMessage;

    final isMedia = _isMedia(rawMessage);
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

    return _synchronized(
      contact.phoneId,
      () => _handleIncoming(
        contact: contact,
        tenant: tenant,
        receivedMessage: receivedMessage,
      ),
    );
  }

  Future<bool> _handleIncoming({
    required ContactEntity contact,
    required TenantConfigEntity tenant,
    required MessageEntity receivedMessage,
  }) async {
    final conversation = await getOrCreateConversation(
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
      await saveConversation(conversation: updatedConversation, tenant: tenant);
      return true;
    }

    if (_isMedia(receivedMessage)) {
      await _handoffToAgent(
        conversation: conversation,
        tenant: tenant,
        receivedMessage: receivedMessage,
      );
      return true;
    }

    await addMessageInConversation(
      conversationId: conversation.id,
      message: receivedMessage,
      tenant: tenant,
    );

    DebounceManager.instance.run(
      conversation.id,
      debounceDuration,
      () => _replyWithAi(
        contact: contact,
        tenant: tenant,
        receivedMessage: receivedMessage,
      ),
    );

    return true;
  }

  /// Hands the conversation over to a human agent as soon as the customer
  /// sends any multimedia: the bot is switched off *before* replying, any
  /// pending AI reply is cancelled and a fixed (non-AI) message pointing to
  /// the catalog is sent.
  Future<void> _handoffToAgent({
    required ConversationEntity conversation,
    required TenantConfigEntity tenant,
    required MessageEntity receivedMessage,
  }) async {
    DebounceManager.instance.cancel(conversation.id);

    await addMessageInConversation(
      conversationId: conversation.id,
      message: receivedMessage,
      tenant: tenant,
    );

    final botOffConversation = conversation.copyWith(
      messages: [...conversation.messages, receivedMessage],
      lastMessage: receivedMessage,
      unreadCount: conversation.unreadCount + 1,
      isBotActive: false,
    );
    await saveConversation(conversation: botOffConversation, tenant: tenant);

    final handoffReply = MessageEntity(
      recipientId: conversation.contact.phoneId,
      senderId: tenant.phoneId,
      senderName: tenant.botName,
      content: buildAgentHandoffMessage(tenant),
      timestamp: DateTime.now(),
    );

    await addMessageInConversation(
      conversationId: conversation.id,
      message: handoffReply,
      tenant: tenant,
    );
    await sendMessage(handoffReply, tenant);

    await saveConversation(
      conversation: botOffConversation.copyWith(
        messages: [...botOffConversation.messages, handoffReply],
        lastMessage: handoffReply,
      ),
      tenant: tenant,
    );
  }

  /// Debounced AI flow. The conversation is re-read before and after the AI
  /// call because a multimedia hand-off (or an agent) may have switched the
  /// bot off in the meantime.
  Future<void> _replyWithAi({
    required ContactEntity contact,
    required TenantConfigEntity tenant,
    required MessageEntity receivedMessage,
  }) async {
    try {
      final updatedConversation = await getOrCreateConversation(
        contact: contact,
        tenant: tenant,
      );

      if (!updatedConversation.isBotActive) {
        _logger.info('Bot is off for ${updatedConversation.id}, skipping AI.');
        return;
      }

      final botReply = await generatedhistoryBasedResponse(
        updatedConversation,
        tenant,
      );

      final latestConversation = await getOrCreateConversation(
        contact: contact,
        tenant: tenant,
      );

      if (!latestConversation.isBotActive) {
        _logger.info(
          'Bot was turned off while generating the reply for '
          '${latestConversation.id}, discarding it.',
        );
        return;
      }

      final isOrder =
          _isOrderSummary(receivedMessage) ||
          _pendingCustomerMessages(latestConversation).any(_isOrderSummary);
      final shouldDeactivate = isOrder || botReply.shouldDeactivateBot;

      await addMessageInConversation(
        conversationId: latestConversation.id,
        message: botReply,
        tenant: tenant,
      );

      await sendMessage(botReply, tenant);

      final finalConversation = latestConversation.copyWith(
        messages: [...latestConversation.messages, botReply],
        lastMessage: botReply,
        unreadCount: latestConversation.unreadCount + 1,
        isBotActive: !shouldDeactivate && latestConversation.isBotActive,
      );

      await saveConversation(conversation: finalConversation, tenant: tenant);
    } catch (e, stackTrace) {
      _logger.severe('Error generating AI reply: $e', e, stackTrace);
    }
  }

  /// Customer messages sent after the last reply from the business.
  Iterable<MessageEntity> _pendingCustomerMessages(
    ConversationEntity conversation,
  ) {
    return conversation.messages.reversed.takeWhile(
      (message) => message.senderId == conversation.id,
    );
  }

  static bool _isMedia(MessageEntity message) {
    return message.type == MessageType.image ||
        message.type == MessageType.audio ||
        message.type == MessageType.video ||
        message.type == MessageType.file;
  }

  static bool _isOrderSummary(MessageEntity message) {
    return message.content.contains('🛒 *Nuevo Pedido') ||
        message.content.contains('*Nuevo Pedido -');
  }

  Future<T> _synchronized<T>(String key, Future<T> Function() action) async {
    final previous = _locks[key];
    final current = Completer<void>();
    _locks[key] = current;
    try {
      if (previous != null) await previous.future;
      return await action();
    } finally {
      current.complete();
      if (identical(_locks[key], current)) _locks.remove(key);
    }
  }
}
