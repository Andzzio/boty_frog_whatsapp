import 'package:boty_frog/domain/entities/contact_entity.dart';
import 'package:boty_frog/domain/entities/conversation_entity.dart';
import 'package:boty_frog/domain/entities/message_entity.dart';
import 'package:boty_frog/domain/entities/tenant_config_entity.dart';

/// Repository interface for managing conversation state and history.
abstract class ConversationRepository {
  /// Gets a conversation by contact and tenant context.
  Future<ConversationEntity?> getConversation({
    required ContactEntity contact,
    required TenantConfigEntity tenant,
  });

  /// Saves a conversation under a specific tenant context.
  Future<void> saveConversation({
    required ConversationEntity conversation,
    required TenantConfigEntity tenant,
  });

  /// Adds a message in a conversation under a specific tenant context.
  Future<void> addMessageInConversation({
    required String conversationId,
    required MessageEntity message,
    required TenantConfigEntity tenant,
  });

  /// Updates the status of a message.
  Future<void> updateMessageStatus({
    required String messageId,
    required String conversationId,
    required String status,
    required TenantConfigEntity tenant,
  });

  /// Associates a WhatsApp message ID to a CRM message document.
  Future<void> associateWhatsappMessageId({
    required String crmMessageId,
    required String whatsappMessageId,
    required String conversationId,
    required TenantConfigEntity tenant,
  });
}
