import 'package:boty_frog/data/models/shipping_zone_model.dart';
import 'package:boty_frog/domain/entities/business_info_entity.dart';

/// Data model representing business information.
class BusinessInfoModel extends BusinessInfoEntity {
  /// Constructs a [BusinessInfoModel] instance.
  BusinessInfoModel({
    required super.paymentMethods,
    required super.shippingZones,
  });

  /// Creates a [BusinessInfoModel] from Firestore data.
  factory BusinessInfoModel.fromFirestore(
    Map<String, dynamic> businessData,
    List<ShippingZoneModel> zones,
  ) {
    final list = businessData['paymentMethods'] as List? ?? [];
    final payments = List<String>.from(list);
    return BusinessInfoModel(
      paymentMethods: payments,
      shippingZones: zones,
    );
  }
}
