import 'package:boty_frog/domain/entities/contact_entity.dart';
import 'package:boty_frog/domain/entities/conversation_entity.dart';

/// Contract of [ConversationLocalDatasource]
abstract class ConversationLocalDatasource {
  /// Returns a [ConversationEntity] by [ContactEntity],
  /// or null if doesn't exist.
  Future<ConversationEntity?> getConversation({
    required ContactEntity contact,
  });

  /// Saves a [ConversationEntity].
  Future<void> saveConversation({required ConversationEntity conversation});
}
