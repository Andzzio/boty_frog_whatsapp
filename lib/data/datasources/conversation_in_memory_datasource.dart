import 'package:boty_frog/domain/datasources/conversation_datasource.dart';
import 'package:boty_frog/domain/entities/contact_entity.dart';
import 'package:boty_frog/domain/entities/conversation_entity.dart';
import 'package:boty_frog/domain/entities/message_entity.dart';
import 'package:boty_frog/domain/entities/tenant_config_entity.dart';

/// In-memory implementation of [ConversationLocalDatasource].
class ConversationInMemoryDatasource implements ConversationLocalDatasource {
  final Map<String, ConversationEntity> _conversations = {};

  @override
  Future<ConversationEntity?> getConversation({
    required ContactEntity contact,
    required TenantConfigEntity tenant,
  }) async {
    return _conversations[contact.phoneId];
  }

  @override
  Future<void> saveConversation({
    required ConversationEntity conversation,
    required TenantConfigEntity tenant,
  }) async {
    _conversations[conversation.contact.phoneId] = conversation;
  }

  @override
  Future<void> addMessageInConversation({
    required String conversationId,
    required MessageEntity message,
    required TenantConfigEntity tenant,
  }) async {
    final conversation = _conversations[conversationId];
    if (conversation != null) {
      conversation.messages.add(message);
    }
  }

  @override
  Future<void> updateMessageStatus({
    required String messageId,
    required String conversationId,
    required String status,
    required TenantConfigEntity tenant,
  }) async {
    final conversation = _conversations[conversationId];
    if (conversation != null) {
      for (var i = 0; i < conversation.messages.length; i++) {
        final msg = conversation.messages[i];
        if (msg.id == messageId) {
          conversation.messages[i] = msg.copyWith(status: status);
        }
      }
    }
  }

  @override
  Future<void> associateWhatsappMessageId({
    required String crmMessageId,
    required String whatsappMessageId,
    required String conversationId,
    required TenantConfigEntity tenant,
  }) async {
    final conversation = _conversations[conversationId];
    if (conversation != null) {
      for (var i = 0; i < conversation.messages.length; i++) {
        final msg = conversation.messages[i];
        if (msg.id == crmMessageId) {
          conversation.messages[i] = msg.copyWith(
            whatsappMessageId: whatsappMessageId,
          );
        }
      }
    }
  }
}
