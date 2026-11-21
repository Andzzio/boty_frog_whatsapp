import 'package:boty_frog/domain/entities/tenant_config_entity.dart';

/// Builds the fixed hand-off message shown when the bot transfers the
/// conversation to a human agent (multimedia or product inquiry).
String buildAgentHandoffMessage(TenantConfigEntity tenant) {
  const base =
      'Se te derivará con un agente especializado para brindarte una '
      'mejor información.';
  final catalogUrl = tenant.catalogUrl.trim();
  if (catalogUrl.isEmpty) return base;
  return '$base\n\nMientras tanto, te invito a ver nuestros productos en '
      'nuestra página web: $catalogUrl';
}
