import 'package:boty_frog/domain/datasources/conversation_local_datasource.dart';
import 'package:boty_frog/domain/entities/contact_entity.dart';
import 'package:boty_frog/domain/entities/conversation_entity.dart';
import 'package:boty_frog/domain/repos/conversation_repository.dart';

/// Conversation Repo Implementation
class ConversationRepositoryImpl implements ConversationRepository {
  /// Constructos for [ConversationRepositoryImpl]
  ConversationRepositoryImpl(this._datasource);

  /// Datasource [ConversationLocalDatasource]
  final ConversationLocalDatasource _datasource;

  @override
  Future<ConversationEntity?> getConversation({
    required ContactEntity contact,
  }) async {
    return _datasource.getConversation(contact: contact);
  }

  @override
  Future<void> saveConversation({
    required ConversationEntity conversation,
  }) async {
    return _datasource.saveConversation(conversation: conversation);
  }
}
