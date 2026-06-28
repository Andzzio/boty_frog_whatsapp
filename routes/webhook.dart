import 'package:boty_frog/core/business_registry.dart';
import 'package:boty_frog/domain/repos/conversation_repository.dart';
import 'package:boty_frog/domain/usecases/process_incoming_message_usecase.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:logging/logging.dart';

final _logger = Logger('WebhookHandler');

Future<Response> onRequest(RequestContext context) async {
  final businessRegistry = context.read<BusinessRegistry>();
  final request = context.request;

  if (request.method == HttpMethod.get) {
    final mode = request.url.queryParameters['hub.mode'];
    final challenge = request.url.queryParameters['hub.challenge'];
    final token = request.url.queryParameters['hub.verify_token'];

    _logger.info('Token recibido: $token');

    if (mode == 'subscribe' &&
        token != null &&
        businessRegistry.verifyTokenExists(token)) {
      _logger.info('Webhook verified successfully');
      return Response(body: challenge);
    }
    _logger.severe('Webhook verification failed');
    return Response(body: 'Verification failed', statusCode: 403);
  }

  if (request.method == HttpMethod.post) {
    final body = await request.json() as Map<String, dynamic>;
    final entries = body['entry'] as List<dynamic>;
    final entry = entries[0] as Map<String, dynamic>;
    final changes = entry['changes'] as List<dynamic>;
    final change = changes[0] as Map<String, dynamic>;
    final value = change['value'] as Map<String, dynamic>;

    if (value.containsKey('statuses')) {
      final statuses = value['statuses'] as List<dynamic>;
      final statusJson = statuses[0] as Map<String, dynamic>;
      final messageId = statusJson['id'] as String;
      final status = statusJson['status'] as String;
      final recipientId = statusJson['recipient_id'] as String;

      final metadata = value['metadata'] as Map<String, dynamic>;
      final phoneNumberId = metadata['phone_number_id'] as String;

      final tenant = businessRegistry.findByPhoneId(phoneNumberId);
      if (tenant != null) {
        final conversationRepository = context.read<ConversationRepository>();
        await conversationRepository.updateMessageStatus(
          messageId: messageId,
          conversationId: '+$recipientId',
          status: status,
          tenant: tenant,
        );
        await conversationRepository.updateMessageStatus(
          messageId: messageId,
          conversationId: recipientId,
          status: status,
          tenant: tenant,
        );
      }
      return Response();
    }

    final contactsJson = value['contacts'] as List<dynamic>?;
    final messagesJson = value['messages'] as List<dynamic>?;

    if (contactsJson == null || messagesJson == null) {
      _logger.warning('Webhook ignored: missing contacts or messages');
      return Response(body: 'Webhook received and ignored');
    }

    final metadata = value['metadata'] as Map<String, dynamic>;
    final phoneNumberId = metadata['phone_number_id'] as String;

    final tenant = businessRegistry.findByPhoneId(phoneNumberId);
    if (tenant == null) {
      _logger.warning('Tenant not found for phone_number_id: $phoneNumberId');
      return Response(body: 'Tenant not found');
    }

    final processIncomingMessage = context
        .read<ProcessIncomingMessageUsecase>();
    try {
      final processed = await processIncomingMessage(
        messageData: value,
        contactsJson: contactsJson,
        tenant: tenant,
      );

      return processed
          ? Response(body: 'Webhook received')
          : Response(body: 'Webhook received and ignored');
    } catch (e, stackTrace) {
      _logger.severe('Error procesando mensaje entrante: $e', e, stackTrace);
      return Response(body: 'Error processed');
    }
  }

  _logger.warning('Method not allowed: ${request.method}');
  return Response(body: 'Error method not allowed', statusCode: 405);
}
