import 'package:boty_frog/domain/datasources/conversation_datasource.dart';
import 'package:boty_frog/domain/entities/contact_entity.dart';
import 'package:boty_frog/domain/entities/conversation_entity.dart';
import 'package:boty_frog/domain/entities/message_entity.dart';
import 'package:boty_frog/domain/entities/tenant_config_entity.dart';
import 'package:boty_frog/domain/repos/conversation_repository.dart';

/// Implementation of [ConversationRepository]
/// delegating to [ConversationLocalDatasource].
class ConversationRepositoryImpl implements ConversationRepository {
  /// Constructs a [ConversationRepositoryImpl]
  /// with the given [_datasource].
  ConversationRepositoryImpl(this._datasource);
  final ConversationLocalDatasource _datasource;

  @override
  Future<ConversationEntity?> getConversation({
    required ContactEntity contact,
    required TenantConfigEntity tenant,
  }) async {
    return _datasource.getConversation(contact: contact, tenant: tenant);
  }

  @override
  Future<void> saveConversation({
    required ConversationEntity conversation,
    required TenantConfigEntity tenant,
  }) async {
    return _datasource.saveConversation(
      conversation: conversation,
      tenant: tenant,
    );
  }

  @override
  Future<void> addMessageInConversation({
    required String conversationId,
    required MessageEntity message,
    required TenantConfigEntity tenant,
  }) async {
    return _datasource.addMessageInConversation(
      conversationId: conversationId,
      message: message,
      tenant: tenant,
    );
  }

  @override
  Future<void> updateMessageStatus({
    required String messageId,
    required String conversationId,
    required String status,
    required TenantConfigEntity tenant,
  }) async {
    return _datasource.updateMessageStatus(
      messageId: messageId,
      conversationId: conversationId,
      status: status,
      tenant: tenant,
    );
  }

  @override
  Future<void> associateWhatsappMessageId({
    required String crmMessageId,
    required String whatsappMessageId,
    required String conversationId,
    required TenantConfigEntity tenant,
  }) async {
    return _datasource.associateWhatsappMessageId(
      crmMessageId: crmMessageId,
      whatsappMessageId: whatsappMessageId,
      conversationId: conversationId,
      tenant: tenant,
    );
  }
}
