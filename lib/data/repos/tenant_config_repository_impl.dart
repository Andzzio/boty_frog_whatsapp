import 'package:boty_frog/domain/datasources/tenant_config_datasource.dart';
import 'package:boty_frog/domain/entities/tenant_config_entity.dart';
import 'package:boty_frog/domain/repos/tenant_config_repository.dart';

/// Implementation of [TenantConfigRepository]
/// that delegates data fetching to [TenantConfigDatasource].
class TenantConfigRepositoryImpl implements TenantConfigRepository {
  /// Constructs a [TenantConfigRepositoryImpl] with the given [_datasource].
  TenantConfigRepositoryImpl(this._datasource);
  final TenantConfigDatasource _datasource;

  @override
  /// Loads all configurations from the datasource.
  Future<List<TenantConfigEntity>> loadAllConfigs() {
    return _datasource.loadAllConfigs();
  }

  @override
  /// Loads the configuration for a specific business ID from the datasource.
  Future<TenantConfigEntity?> getConfigByBusinessId(String businessId) {
    return _datasource.getConfigByBusinessId(businessId);
  }
}
