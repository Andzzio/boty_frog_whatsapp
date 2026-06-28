/// Entity representing a shipping zone.
class ShippingZoneEntity {
  /// Constructs a [ShippingZoneEntity] instance.
  ShippingZoneEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
  });

  /// The unique identifier of the shipping zone.
  final String id;

  /// The name of the shipping zone.
  final String name;

  /// The cost of shipping to this zone.
  final double price;

  /// A brief description of the shipping zone.
  final String description;
}
