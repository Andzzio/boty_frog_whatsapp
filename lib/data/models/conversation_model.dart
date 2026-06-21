import 'package:boty_frog/data/models/contact_model.dart';
import 'package:boty_frog/data/models/message_model.dart';
import 'package:boty_frog/domain/entities/conversation_entity.dart';

/// Model representing a conversation in the application.
class ConversationModel extends ConversationEntity {
  /// Constructs a [ConversationModel] with the given parameters.
  ConversationModel({
    required super.id,
    required super.contact,
    required super.messages,
    required super.unreadCount,
    super.lastMessage,
    super.isBotActive,
  });

  /// Creates a [ConversationModel] from a Firestore JSON map.
  factory ConversationModel.fromFirestore(
    Map<String, dynamic> json,
    String id,
  ) {
    final contactMap = json['contact'] as Map<String, dynamic>;
    final lastMsgMap = json['lastMessage'] as Map<String, dynamic>?;
    return ConversationModel(
      id: id,
      contact: ContactModel.fromJson(contactMap),
      unreadCount: json['unreadCount'] as int? ?? 0,
      messages: [],
      lastMessage: lastMsgMap != null
          ? MessageModel.fromJson(lastMsgMap)
          : null,
      isBotActive: json['isBotActive'] as bool? ?? true,
    );
  }

  /// Converts the [ConversationModel] to a Firestore JSON map.
  Map<String, dynamic> toFirestore() {
    return {
      'contact': {
        'name': contact.name,
        'phoneId': contact.phoneId,
      },
      'unreadCount': unreadCount,
      'lastMessage': lastMessage != null
          ? MessageModel.fromEntity(lastMessage!).toJson()
          : null,
      'isBotActive': isBotActive,
    };
  }
}
