/// Entity representing a variant of a product.
class ProductVariantEntity {
  /// Constructs a [ProductVariantEntity] instance.
  ProductVariantEntity({
    required this.name,
    required this.price,
    required this.stock,
    required this.sizes,
    this.sku,
    this.color,
    this.discountPrice,
  });

  /// The stock keeping unit.
  final String? sku;

  /// The name of the variant.
  final String name;

  /// The color code of the variant.
  final int? color;

  /// The stock count of the variant.
  final int stock;

  /// The list of available sizes.
  final List<String> sizes;

  /// The price of the variant.
  final double price;

  /// The discount price if applicable.
  final double? discountPrice;
}
