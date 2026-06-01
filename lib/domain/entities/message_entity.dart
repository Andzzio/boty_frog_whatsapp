/// Entity representing a message in the application.
class MessageEntity {
  /// Constructs a [MessageEntity] with the given parameters.
  MessageEntity({
    required this.recipientId,
    required this.senderId,
    required this.senderName,
    required this.content,
    this.timestamp,
    this.id,
    this.isRead = false,
    this.type = MessageType.text,
  });

  /// The unique identifier for the message.
  final String? id;

  /// The identifier of the use who recivied the message.
  final String recipientId;

  /// The identifier of the user who sent the message.
  final String senderId;

  /// The name of the user who sent the message.
  final String senderName;

  /// The content of the message.
  final String content;

  /// The timestamp when the message was sent.
  final DateTime? timestamp;

  /// Indicates whether the message has been read.
  final bool isRead;

  /// The type of the message.
  final MessageType type;

  /// Creates a copy of the [MessageEntity] with the given parameters.
  MessageEntity copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    MessageType? type,
    String? recipientId,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      recipientId: recipientId ?? this.recipientId,
    );
  }
}

/// Enum representing the different types of messages.
enum MessageType {
  /// A text message.
  text,

  /// An image message.
  image,

  /// A video message.
  video,

  /// An audio message.
  audio,

  /// A file message.
  file,

  /// A payment link message.
  paymentLink;

  /// Converts a string to a [MessageType] enum value.
  static MessageType fromString(String type) {
    return MessageType.values.firstWhere(
      (element) => element.name == type.toLowerCase(),
      orElse: () => MessageType.text,
    );
  }

  /// Converts the [MessageType] enum value to a string format suitable.
  String toWhatsappFormat() {
    return name;
  }
}
