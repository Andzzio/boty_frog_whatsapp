import 'package:boty_frog/domain/entities/message_entity.dart';

/// Model representing a message in the application.
class MessageModel extends MessageEntity {
  /// Constructs a [MessageModel] with the given parameters.
  MessageModel({
    required super.id,
    required super.senderId,
    required super.content,
    required super.timestamp,
    super.isRead,
    super.type,
  });

  /// Creates a [MessageModel] from a JSON map.
  factory MessageModel.fromWhatsappJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool,
      type: MessageType.fromString(json['type'] as String),
    );
  }

  /// Converts the [MessageModel] to a [MessageEntity].
  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      senderId: senderId,
      content: content,
      timestamp: timestamp,
      isRead: isRead,
      type: type,
    );
  }
}
