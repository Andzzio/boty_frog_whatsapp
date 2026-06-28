import 'package:boty_frog/domain/entities/business_info_entity.dart';
import 'package:boty_frog/domain/repos/business_info_repository.dart';

/// Usecase to retrieve business info.
class GetBusinessInfoUsecase {
  /// Constructs a [GetBusinessInfoUsecase] instance.
  GetBusinessInfoUsecase(this._repository);

  final BusinessInfoRepository _repository;

  /// Retrieves the business info for the given [businessId].
  Future<BusinessInfoEntity> call(String businessId) {
    return _repository.getBusinessInfo(businessId);
  }
}
