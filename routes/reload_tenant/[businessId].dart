import 'package:boty_frog/core/business_registry.dart';
import 'package:boty_frog/domain/repos/tenant_config_repository.dart';
import 'package:dart_frog/dart_frog.dart';

/// Handles requests to POST /reload_tenant/[businessId] to reload a business configuration in hot memory.
Future<Response> onRequest(RequestContext context, String businessId) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }

  try {
    final repository = context.read<TenantConfigRepository>();
    final registry = context.read<BusinessRegistry>();

    final tenantConfig = await repository.getConfigByBusinessId(businessId);
    if (tenantConfig == null) {
      return Response(
        statusCode: 404,
        body: 'Tenant configuration not found for businessId: $businessId',
      );
    }

    registry.register(tenantConfig);

    return Response(body: 'Tenant configuration reloaded successfully');
  } catch (e) {
    return Response(statusCode: 500, body: 'Internal Server Error: $e');
  }
}
