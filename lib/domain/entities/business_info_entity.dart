import 'package:boty_frog/domain/entities/shipping_zone_entity.dart';

/// Entity representing general information about a business.
class BusinessInfoEntity {
  /// Constructs a [BusinessInfoEntity] instance.
  BusinessInfoEntity({
    required this.paymentMethods,
    required this.shippingZones,
  });

  /// The list of payment methods accepted by the business.
  final List<String> paymentMethods;

  /// The list of shipping zones configured for the business.
  final List<ShippingZoneEntity> shippingZones;
}
