import 'package:boty_frog/domain/entities/contact_entity.dart';
import 'package:boty_frog/domain/entities/message_entity.dart';

/// Define a conversation.
class ConversationEntity {
  /// Constructor for a conversation.
  ConversationEntity({
    required this.contact,
    required this.id,
    required this.unreadCount,
    this.lastMessage,
    this.isBotActive = true,
    List<MessageEntity>? messages,
  }) : messages = messages ?? [];

  /// Contact of the conversation.
  final ContactEntity contact;

  /// History of the conversation.
  final List<MessageEntity> messages;

  /// Identificator for [ConversationEntity].
  final String id;

  /// Counts unread [MessageEntity].
  final int unreadCount;

  /// Last [MessageEntity] sent.
  final MessageEntity? lastMessage;

  /// Indicates if the bot is active for this conversation.
  final bool isBotActive;

  /// Clones [ConversationEntity] and returns it.
  ConversationEntity copyWith({
    ContactEntity? contact,
    String? id,
    int? unreadCount,
    MessageEntity? lastMessage,
    bool? isBotActive,
    List<MessageEntity>? messages,
  }) {
    return ConversationEntity(
      contact: contact ?? this.contact,
      id: id ?? this.id,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessage: lastMessage ?? this.lastMessage,
      isBotActive: isBotActive ?? this.isBotActive,
      messages: messages ?? this.messages,
    );
  }
}
