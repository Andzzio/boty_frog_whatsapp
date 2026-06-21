import 'package:boty_frog/domain/entities/message_entity.dart';
import 'package:boty_frog/domain/entities/tenant_config_entity.dart';
import 'package:boty_frog/domain/repos/ai_response_repository.dart';

/// Usecase to trigger simple AI text generation.
class GenerateSimpleResponseUsecase {
  /// Constructs a [GenerateSimpleResponseUsecase]
  /// with the given [AiResponseRepository].
  GenerateSimpleResponseUsecase(this._repository);
  final AiResponseRepository _repository;

  /// Invokes the usecase to generate a simple response for a message.
  Future<MessageEntity> call(
    MessageEntity message,
    TenantConfigEntity tenant,
  ) async {
    return _repository.generateSimpleResponse(message, tenant);
  }
}
