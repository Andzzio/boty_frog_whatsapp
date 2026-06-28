import 'package:boty_frog/domain/entities/shipping_zone_entity.dart';

/// Data model representing a shipping zone.
class ShippingZoneModel extends ShippingZoneEntity {
  /// Constructs a [ShippingZoneModel] instance.
  ShippingZoneModel({
    required super.id,
    required super.name,
    required super.price,
    required super.description,
  });

  /// Creates a [ShippingZoneModel] from a JSON map and document ID.
  factory ShippingZoneModel.fromJson(Map<String, dynamic> json, String id) {
    return ShippingZoneModel(
      id: id,
      name: json['name'] as String? ?? '',
      price: (json['price'] as num? ?? 0.0).toDouble(),
      description: json['description'] as String? ?? '',
    );
  }

  /// Converts this model instance into a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'description': description,
    };
  }
}
