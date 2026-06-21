import 'package:boty_frog/domain/entities/tenant_config_entity.dart';

/// Registry to cache tenant configurations in memory.
class BusinessRegistry {
  final Map<String, TenantConfigEntity> _byPhoneId = {};
  final Map<String, TenantConfigEntity> _byBusinessId = {};

  /// Finds a tenant configuration by WhatsApp Phone ID.
  TenantConfigEntity? findByPhoneId(String phoneId) => _byPhoneId[phoneId];

  /// Finds a tenant configuration by Business ID.
  TenantConfigEntity? findByBusinessId(
    String businessId,
  ) => _byBusinessId[businessId];

  /// Registers all configurations in the registry.
  void registerAll(List<TenantConfigEntity> configs) {
    _byPhoneId.clear();
    _byBusinessId.clear();
    for (final config in configs) {
      _byPhoneId[config.phoneId] = config;
      _byBusinessId[config.businessId] = config;
    }
  }

  /// Registers a configuration in the registry.
  void register(TenantConfigEntity config) {
    _byPhoneId[config.phoneId] = config;
    _byBusinessId[config.businessId] = config;
  }

  /// Verifies if a given verify token exists in the registered tenants.
  bool verifyTokenExists(String token) {
    return _byBusinessId.values.any((config) => config.verifyToken == token);
  }
}
