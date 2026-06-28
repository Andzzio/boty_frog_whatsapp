import 'package:boty_frog/domain/entities/business_info_entity.dart';

/// Abstract datasource interface for retrieving business info.
abstract class BusinessInfoDatasource {
  /// Retrieves the business info for the given [businessId].
  Future<BusinessInfoEntity> getBusinessInfo(String businessId);

  /// Saves or updates the business info for the given [businessId].
  Future<void> updateBusinessInfo(String businessId, BusinessInfoEntity info);
}
