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
    final body = await request.body();
    _logger.info('Messages received: $body');
    return Response(body: 'Webhook received');
  }

  _logger.warning('Method not allowed: ${request.method}');
  return Response(body: 'Error method not allowed', statusCode: 405);
}
