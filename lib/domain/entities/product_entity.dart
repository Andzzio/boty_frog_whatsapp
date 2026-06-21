import 'package:boty_frog/domain/entities/product_variant_entity.dart';

/// Entity representing a product in the catalog.
class ProductEntity {
  /// Constructs a [ProductEntity] instance.
  ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.businessId,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    required this.variants,
    this.salesCount = 0,
    this.isAvailable = true,
    this.sku,
  });

  /// The unique identifier of the product.
  final String id;

  /// The business identifier associated with the product.
  final String businessId;

  /// The stock keeping unit.
  final String? sku;

  /// The name of the product.
  final String name;

  /// The product description.
  final String description;

  /// The date when the product was created.
  final DateTime createdAt;

  /// The date when the product was last updated.
  final DateTime updatedAt;

  /// The product category name.
  final String category;

  /// Indicates whether the product is available.
  final bool isAvailable;

  /// The total sales count.
  final int salesCount;

  /// The list of image URLs for the product.
  final List<String> imageUrl;

  /// The list of variants for this product.
  final List<ProductVariantEntity> variants;
}
