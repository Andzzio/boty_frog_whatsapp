import 'package:boty_frog/domain/entities/contact_entity.dart';
import 'package:boty_frog/domain/entities/message_entity.dart';

/// Define a conversation.
class ConversationEntity {
  /// Constructor for a conversation.
  ConversationEntity({required this.contact, List<MessageEntity>? messages})
    : messages = messages ?? [];

  /// Contact of the conversation.
  final ContactEntity contact;

  /// History of the conversation.
  final List<MessageEntity> messages;
}
