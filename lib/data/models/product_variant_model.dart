import 'package:boty_frog/domain/entities/product_variant_entity.dart';

/// Data model representing a product variant.
class ProductVariantModel extends ProductVariantEntity {
  /// Constructs a [ProductVariantModel] instance.
  ProductVariantModel({
    required super.name,
    required super.stock,
    required super.sizes,
    required super.price,
    super.sku,
    super.color,
    super.discountPrice,
  });

  /// Creates a [ProductVariantModel] from a JSON map.
  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      sku: json['sku'] as String?,
      name: json['name'] as String? ?? '',
      color: json['color'] as int?,
      stock: json['stock'] as int? ?? 0,
      sizes: List<String>.from(json['sizes'] as List? ?? []),
      price: (json['price'] as num? ?? 0.0).toDouble(),
      discountPrice: json['discountPrice'] != null
          ? (json['discountPrice'] as num).toDouble()
          : null,
    );
  }

  /// Creates a [ProductVariantModel] from a [ProductVariantEntity].
  factory ProductVariantModel.fromEntity(ProductVariantEntity entity) {
    return ProductVariantModel(
      sku: entity.sku,
      name: entity.name,
      color: entity.color,
      stock: entity.stock,
      sizes: entity.sizes,
      price: entity.price,
      discountPrice: entity.discountPrice,
    );
  }

  /// Converts the [ProductVariantModel] to a JSON map.
  Map<String, dynamic> toJson() => {
    'sku': sku,
    'name': name,
    'color': color,
    'stock': stock,
    'sizes': sizes,
    'price': price,
    'discountPrice': discountPrice,
  };

  /// Converts the model to its base entity.
  ProductVariantEntity toEntity() => ProductVariantEntity(
    sku: sku,
    name: name,
    color: color,
    stock: stock,
    sizes: sizes,
    price: price,
    discountPrice: discountPrice,
  );
}
