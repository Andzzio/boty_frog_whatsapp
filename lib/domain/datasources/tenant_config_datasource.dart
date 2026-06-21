import 'package:boty_frog/domain/entities/tenant_config_entity.dart';

/// Datasource interface for loading tenant configurations.
abstract class TenantConfigDatasource {
  /// Loads all tenant configurations.
  Future<List<TenantConfigEntity>> loadAllConfigs();

  /// Gets a tenant configuration by its business ID.
  Future<TenantConfigEntity?> getConfigByBusinessId(String businessId);
}
