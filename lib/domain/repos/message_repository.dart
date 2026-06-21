import 'package:boty_frog/domain/entities/message_entity.dart';
import 'package:boty_frog/domain/entities/tenant_config_entity.dart';

/// Repository interface to send and process WhatsApp messages.
abstract class MessageRepository {
  /// Sends a message using the credentials from the [tenant] configuration.
  Future<MessageEntity> sendMessage(
    MessageEntity message,
    TenantConfigEntity tenant,
  );

  /// Parses incoming webhook payload data into a [MessageEntity].
  Future<MessageEntity> receiveMessage(Map<String, dynamic> messageData);
}
