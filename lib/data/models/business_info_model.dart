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
    final payments = list.map((item) {
      if (item is Map) {
        final name = item['name'] as String? ?? '';
        final description = item['description'] as String? ?? '';
        if (description.isNotEmpty) {
          return '$name ($description)';
        }
        return name;
      }
      return item.toString();
    }).toList();
    return BusinessInfoModel(
      paymentMethods: payments,
      shippingZones: zones,
    );
  }
}
