import 'package:boty_frog/domain/datasources/business_info_datasource.dart';
import 'package:boty_frog/domain/entities/business_info_entity.dart';
import 'package:boty_frog/domain/repos/business_info_repository.dart';

/// Implementation of [BusinessInfoRepository].
class BusinessInfoRepositoryImpl implements BusinessInfoRepository {
  /// Constructs a [BusinessInfoRepositoryImpl] instance.
  BusinessInfoRepositoryImpl(this._datasource);

  final BusinessInfoDatasource _datasource;

  @override
  Future<BusinessInfoEntity> getBusinessInfo(String businessId) {
    return _datasource.getBusinessInfo(businessId);
  }

  @override
  Future<void> updateBusinessInfo(
    String businessId,
    BusinessInfoEntity info,
  ) {
    return _datasource.updateBusinessInfo(businessId, info);
  }
}
