import 'package:boty_frog/domain/entities/message_entity.dart';

/// Model representing a message in the application.
class MessageModel extends MessageEntity {
  /// Constructs a [MessageModel] with the given parameters.
  MessageModel({
    required super.recipientId,
    required super.senderId,
    required super.senderName,
    required super.content,
    super.id,
    super.timestamp,
    super.isRead,
    super.type,
    super.media,
    super.status,
    super.whatsappMessageId,
  });

  /// Creates a [MessageModel] from a JSON map.
  factory MessageModel.fromWhatsappJson(Map<String, dynamic> value) {
    final contacts = value['contacts'] as List<dynamic>;
    final contact = contacts[0] as Map<String, dynamic>;
    final profile = contact['profile'] as Map<String, dynamic>;
    final messages = value['messages'] as List<dynamic>;
    final message = messages[0] as Map<String, dynamic>;
    final metadata = value['metadata'] as Map<String, dynamic>;

    final typeStr = message['type'] as String? ?? 'text';
    final type = MessageType.fromString(typeStr);

    var content = '';
    String? media;
    if (type == MessageType.text) {
      final text = message['text'] as Map<String, dynamic>?;
      content = text?['body'] as String? ?? '';
    } else if (type == MessageType.image) {
      final image = message['image'] as Map<String, dynamic>?;
      content = image?['caption'] as String? ?? '';
      media = image?['id'] as String?;
    } else if (type == MessageType.audio) {
      final audio = message['audio'] as Map<String, dynamic>?;
      content = '';
      media = audio?['id'] as String?;
    } else if (type == MessageType.video) {
      final video = message['video'] as Map<String, dynamic>?;
      content = video?['caption'] as String? ?? '';
      media = video?['id'] as String?;
    } else if (type == MessageType.file) {
      final document = message['document'] as Map<String, dynamic>?;
      content = '';
      media = document?['id'] as String?;
    } else {
      content = '';
    }

    return MessageModel(
      id: message['id'].toString(),
      senderId: contact['wa_id'] as String,
      recipientId: metadata['phone_number_id'] as String,
      senderName: profile['name'] as String,
      content: content,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        int.parse(message['timestamp'] as String? ?? '0') * 1000,
      ),
      type: type,
      media: media,
    );
  }

  /// Creates a [MessageModel] from a [MessageEntity].
  factory MessageModel.fromEntity(MessageEntity entity) {
    return MessageModel(
      id: entity.id,
      senderId: entity.senderId,
      recipientId: entity.recipientId,
      senderName: entity.senderName,
      content: entity.content,
      timestamp: entity.timestamp,
      isRead: entity.isRead,
      type: entity.type,
      media: entity.media,
      status: entity.status,
    );
  }

  /// Creates a [MessageModel] from a JSON map.
  factory MessageModel.fromJson(Map<String, dynamic> json, {String? id}) {
    DateTime? parsedTime;
    final rawTime = json['timestamp'];
    if (rawTime is DateTime) {
      parsedTime = rawTime;
    } else if (rawTime is String) {
      parsedTime = DateTime.tryParse(rawTime);
    } else if (rawTime is int) {
      parsedTime = DateTime.fromMillisecondsSinceEpoch(rawTime);
    }
    return MessageModel(
      id: id ?? json['id'] as String?,
      recipientId: json['recipientId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      senderName: json['senderName'] as String? ?? '',
      content: json['content'] as String? ?? '',
      timestamp: parsedTime,
      isRead: json['isRead'] as bool? ?? false,
      type: MessageType.fromString(json['type'] as String? ?? 'text'),
      media: json['media'] as String?,
      status: json['status'] as String?,
    );
  }

  /// Converts the [MessageModel] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'recipientId': recipientId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': timestamp,
      'isRead': isRead,
      'type': type.name,
      'media': media,
      'status': status,
    };
  }

  /// Converts the [MessageModel] to a JSON map suitable for WhatsApp API.
  Map<String, dynamic> toWhatsappJson() {
    final basePayload = <String, dynamic>{
      'messaging_product': 'whatsapp',
      'recipient_type': 'individual',
      'to': recipientId,
    };

    switch (type) {
      case MessageType.text:
        return {
          ...basePayload,
          'type': 'text',
          'text': {'preview_url': false, 'body': content},
        };
      case MessageType.paymentLink:
        return {
          ...basePayload,
          'type': 'text',
          'text': {'preview_url': true, 'body': content},
        };
      case MessageType.image:
        return {
          ...basePayload,
          'type': 'image',
          'image': {
            'link': media,
            if (content.isNotEmpty) 'caption': content,
          },
        };
      case MessageType.video:
        return {
          ...basePayload,
          'type': 'video',
          'video': {
            'link': media,
            if (content.isNotEmpty) 'caption': content,
          },
        };
      case MessageType.audio:
        return {
          ...basePayload,
          'type': 'audio',
          'audio': {
            'link': media,
          },
        };
      case MessageType.file:
        final filename = _getFilenameFromUrl(media ?? '');
        return {
          ...basePayload,
          'type': 'document',
          'document': {
            'link': media,
            'filename': filename,
            if (content.isNotEmpty) 'caption': content,
          },
        };
    }
  }

  String _getFilenameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.pathSegments.last;
      final decodedPath = Uri.decodeComponent(path);
      return decodedPath.split('/').last;
    } catch (_) {
      return 'documento.pdf';
    }
  }

  /// Converts the [MessageModel] to a JSON map suitable for Claude API.
  Map<String, dynamic> toClaudeJson(String conversationId) {
    final role = senderId == conversationId ? 'user' : 'assistant';
    final finalContent = switch (type) {
      MessageType.text => content,
      MessageType.image => '[Imagen enviada]',
      MessageType.audio => '[Audio enviado]',
      MessageType.video => '[Video enviado]',
      MessageType.file => '[Archivo enviado]',
      MessageType.paymentLink => '[Link de pago de Izipay enviado]',
    };

    return {'role': role, 'content': finalContent};
  }

  /// Converts the [MessageModel] to a [MessageEntity].
  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      senderId: senderId,
      recipientId: recipientId,
      senderName: senderName,
      content: content,
      timestamp: timestamp,
      isRead: isRead,
      type: type,
      media: media,
      status: status,
    );
  }
}
