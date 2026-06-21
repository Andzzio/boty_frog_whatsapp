import 'package:boty_frog/domain/entities/message_entity.dart';
import 'package:boty_frog/domain/entities/tenant_config_entity.dart';
import 'package:boty_frog/domain/repos/message_repository.dart';

/// Usecase to send a message via the remote repository.
class SendMessageUsecase {
  /// Constructs a [SendMessageUsecase] with the given [MessageRepository].
  SendMessageUsecase({required MessageRepository messageRepository})
    : _messageRepository = messageRepository;

  final MessageRepository _messageRepository;

  /// Invokes the usecase to send the message
  /// under the tenant configuration context.
  Future<MessageEntity> call(
    MessageEntity message,
    TenantConfigEntity tenant,
  ) async {
    return _messageRepository.sendMessage(message, tenant);
  }
}
