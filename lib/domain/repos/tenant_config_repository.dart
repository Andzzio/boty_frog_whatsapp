import 'package:boty_frog/domain/entities/tenant_config_entity.dart';

/// Repository interface for managing tenant configurations.
abstract class TenantConfigRepository {
  /// Loads all tenant configurations.
  Future<List<TenantConfigEntity>> loadAllConfigs();

  /// Gets a tenant configuration by its business ID.
  Future<TenantConfigEntity?> getConfigByBusinessId(String businessId);
}
