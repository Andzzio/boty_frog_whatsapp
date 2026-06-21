import 'package:boty_frog/domain/entities/message_entity.dart';
import 'package:boty_frog/domain/entities/tenant_config_entity.dart';

/// Remote datasource interface to handle sending and receiving messages.
abstract class MessageRemoteDatasource {
  /// Sends a message using the credentials from the [tenant] configuration.
  Future<MessageEntity> sendMessage(
    MessageEntity message,
    TenantConfigEntity tenant,
  );

  /// Parsers incoming webhook payload data into a [MessageEntity].
  Future<MessageEntity> receiveMessage(Map<String, dynamic> messageData);
}
