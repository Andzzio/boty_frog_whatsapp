import 'package:boty_frog/domain/entities/business_info_entity.dart';

/// Repository interface for business info operations.
abstract class BusinessInfoRepository {
  /// Gets the business info by [businessId].
  Future<BusinessInfoEntity> getBusinessInfo(String businessId);

  /// Updates the business info.
  Future<void> updateBusinessInfo(String businessId, BusinessInfoEntity info);
}
