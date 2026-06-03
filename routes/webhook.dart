import 'package:boty_frog/domain/usecases/generate_history_based_response.dart';
import 'package:boty_frog/domain/usecases/get_contact_usecase.dart';
import 'package:boty_frog/domain/usecases/get_or_create_conversation_usecase.dart';
import 'package:boty_frog/domain/usecases/receive_message_usecase.dart';
import 'package:boty_frog/domain/usecases/save_conversation_usecase.dart';
import 'package:boty_frog/domain/usecases/send_message_usecase.dart';
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

    final receiveMessage = context.read<ReceiveMessageUsecase>();
    final getContact = context.read<GetContactUsecase>();
    final getOrCreateConversation = context
        .read<GetOrCreateConversationUsecase>();
    final saveConversation = context.read<SaveConversationUsecase>();
    final generatedhistoryBasedResponse = context
        .read<GenerateHistoryBasedResponse>();
    final sendMessage = context.read<SendMessageUsecase>();

    final receivedMessage = await receiveMessage(value);

    _logger.info(
      'Messages received: ${receivedMessage.content} '
      'from ${receivedMessage.senderName}',
    );

    final contact = await getContact(contactsJson);

    if (contact == null) {
      _logger.warning('No contact found in webhook payload, ignoring...');
      return Response(body: 'Webhook received and ignored');
    }

    final conversation = await getOrCreateConversation(
      contact: contact,
    );

    conversation.messages.add(receivedMessage);

    final botReply = await generatedhistoryBasedResponse(conversation);

    conversation.messages.add(botReply);

    await saveConversation(conversation: conversation);

    await sendMessage(botReply);

    return Response(body: 'Webhook received');
  }

  _logger.warning('Method not allowed: ${request.method}');
  return Response(body: 'Error method not allowed', statusCode: 405);
}
