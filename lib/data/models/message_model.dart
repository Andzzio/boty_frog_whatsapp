import 'package:boty_frog/domain/entities/message_entity.dart';

/// Model representing a message in the application.
class MessageModel extends MessageEntity {
  /// Constructs a [MessageModel] with the given parameters.
  MessageModel({
    required super.senderId,
    required super.senderName,
    required super.content,
    super.id,
    super.timestamp,
    super.isRead,
    super.type,
  });

  /// Creates a [MessageModel] from a JSON map.
  factory MessageModel.fromWhatsappJson(Map<String, dynamic> value) {
    final contacts = value['contacts'] as List<dynamic>;
    final contact = contacts[0] as Map<String, dynamic>;
    final profile = contact['profile'] as Map<String, dynamic>;
    final messages = value['messages'] as List<dynamic>;
    final message = messages[0] as Map<String, dynamic>;
    final text = message['text'] as Map<String, dynamic>;

    return MessageModel(
      id: message['id'].toString(),
      senderId: contact['wa_id'] as String,
      senderName: profile['name'] as String,
      content: text['body'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        int.parse(message['timestamp'] as String) * 1000,
      ),
      type: MessageType.fromString(message['type'] as String),
    );
  }

  /// Creates a [MessageModel] from a [MessageEntity].
  factory MessageModel.fromEntity(MessageEntity entity) {
    return MessageModel(
      id: entity.id,
      senderId: entity.senderId,
      senderName: entity.senderName,
      content: entity.content,
      timestamp: entity.timestamp,
      isRead: entity.isRead,
      type: entity.type,
    );
  }

  /// Converts the [MessageModel] to a JSON map suitable for WhatsApp API.
  Map<String, dynamic> toWhatsappJson() {
    return {
      'messaging_product': 'whatsapp',
      'recipient_type': 'individual',
      'to': senderId,
      'type': 'text',
      'text': {'preview_url': false, 'body': content},
    };
  }

  /// Converts the [MessageModel] to a [MessageEntity].
  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      senderId: senderId,
      senderName: senderName,
      content: content,
      timestamp: timestamp,
      isRead: isRead,
      type: type,
    );
  }
}
