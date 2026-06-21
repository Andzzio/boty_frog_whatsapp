import 'package:boty_frog/core/business_registry.dart';
import 'package:boty_frog/domain/entities/message_entity.dart';
import 'package:boty_frog/domain/repos/conversation_repository.dart';
import 'package:boty_frog/domain/usecases/send_message_usecase.dart';
import 'package:dart_frog/dart_frog.dart';

/// Handles requests to POST /send_message to dispatch a message on behalf of a specific tenant.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }

  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final businessId = body['businessId'] as String?;
    final to = body['to'] as String?;
    final content = body['content'] as String? ?? '';
    final typeStr = body['type'] as String? ?? 'text';
    final media = body['media'] as String?;

    if (businessId == null || to == null) {
      return Response(
        statusCode: 400,
        body: 'Missing required fields: businessId, to',
      );
    }

    final registry = context.read<BusinessRegistry>();
    final tenant = registry.findByBusinessId(businessId);

    if (tenant == null) {
      return Response(statusCode: 404, body: 'Business not found');
    }

    final messageId = body['messageId'] as String?;

    final message = MessageEntity(
      recipientId: to,
      senderId: tenant.phoneId,
      senderName: tenant.botName,
      content: content,
      timestamp: DateTime.now(),
      type: MessageType.fromString(typeStr),
      media: media,
    );

    final sendMessageUsecase = context.read<SendMessageUsecase>();
    final sentMessage = await sendMessageUsecase(message, tenant);

    if (messageId != null && sentMessage.id != null) {
      final conversationRepository = context.read<ConversationRepository>();
      await conversationRepository.associateWhatsappMessageId(
        crmMessageId: messageId,
        whatsappMessageId: sentMessage.id!,
        conversationId: to,
        tenant: tenant,
      );
    }

    return Response(body: 'Message sent successfully');
  } catch (e) {
    return Response(statusCode: 500, body: 'Internal Server Error: $e');
  }
}
