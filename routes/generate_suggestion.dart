import 'package:boty_frog/core/business_registry.dart';
import 'package:boty_frog/domain/entities/contact_entity.dart';
import 'package:boty_frog/domain/usecases/generate_history_based_response.dart';
import 'package:boty_frog/domain/usecases/get_or_create_conversation_usecase.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }

  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final businessId = body['businessId'] as String?;
    final conversationId = body['conversationId'] as String?;
    final clientName = body['clientName'] as String? ?? 'Cliente';

    if (businessId == null || conversationId == null) {
      return Response(
        statusCode: 400,
        body: 'Missing required fields: businessId, conversationId',
      );
    }

    final registry = context.read<BusinessRegistry>();
    final tenant = registry.findByBusinessId(businessId);

    if (tenant == null) {
      return Response(statusCode: 404, body: 'Business not found');
    }

    final contact = ContactEntity(name: clientName, phoneId: conversationId);

    final getOrCreateConversation =
        context.read<GetOrCreateConversationUsecase>();
    final generateHistoryBasedResponse =
        context.read<GenerateHistoryBasedResponse>();

    final conversation = await getOrCreateConversation(
      contact: contact,
      tenant: tenant,
    );

    final responseMessage = await generateHistoryBasedResponse(
      conversation,
      tenant,
    );

    return Response.json(
      body: {
        'suggestion': responseMessage.content,
      },
    );
  } catch (e) {
    return Response(statusCode: 500, body: 'Internal Server Error: $e');
  }
}
