import 'package:boty_frog/domain/usecases/process_incoming_message_usecase.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dotenv/dotenv.dart';
import 'package:logging/logging.dart';

final _logger = Logger('WebhookHandler');
Future<Response> onRequest(RequestContext context) async {
  final env = context.read<DotEnv>();
  final request = context.request;

  if (request.method == HttpMethod.get) {
    final verifyToken = env['VERIFY_TOKEN'];
    final mode = request.url.queryParameters['hub.mode'];
    final challenge = request.url.queryParameters['hub.challenge'];
    final token = request.url.queryParameters['hub.verify_token'];

    _logger
      ..info('Token recibido: $token')
      ..info('Token esperado: $verifyToken');

    if (mode == 'subscribe' && token == verifyToken) {
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
    final contactsJson = value['contacts'] as List<dynamic>;
    if (value.containsKey('statuses')) {
      return Response();
    }

    final processIncomingMessage = context
        .read<ProcessIncomingMessageUsecase>();
    final processed = await processIncomingMessage(
      messageData: value,
      contactsJson: contactsJson,
    );

    return processed
        ? Response(body: 'Webhook received')
        : Response(body: 'Webhook received and ignored');
  }

  _logger.warning('Method not allowed: ${request.method}');
  return Response(body: 'Error method not allowed', statusCode: 405);
}
