import 'package:boty_frog/domain/datasources/conversation_datasource.dart';
import 'package:boty_frog/domain/entities/contact_entity.dart';
import 'package:boty_frog/domain/entities/conversation_entity.dart';
import 'package:boty_frog/domain/entities/message_entity.dart';

/// Conversation in memory Datasource implementation.
class ConversationInMemoryDatasource implements ConversationLocalDatasource {
  /// Map of the conversations.
  final Map<String, ConversationEntity> _conversations = {};

  @override
  Future<ConversationEntity?> getConversation({
    required ContactEntity contact,
  }) async {
    return _conversations[contact.phoneId];
  }

  @override
  Future<void> saveConversation({
    required ConversationEntity conversation,
  }) async {
    _conversations[conversation.contact.phoneId] = conversation;
  }

  @override
  Future<void> addMessageInConversation({
    required String conversationId,
    required MessageEntity message,
  }) async {
    final conversation = _conversations[conversationId];
    if (conversation != null) {
      conversation.messages.add(message);
    }
  }
}
