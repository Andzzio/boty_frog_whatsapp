import 'package:boty_frog/data/models/product_variant_model.dart';
import 'package:boty_frog/domain/entities/product_entity.dart';
import 'package:google_cloud_firestore/google_cloud_firestore.dart';

/// Data model representing a product.
class ProductModel extends ProductEntity {
  /// Constructs a [ProductModel] instance.
  ProductModel({
    required super.id,
    required super.businessId,
    required super.name,
    required super.description,
    required super.createdAt,
    required super.updatedAt,
    required super.category,
    required super.imageUrl,
    required super.variants,
    super.isAvailable = true,
    super.salesCount = 0,
    super.sku,
  });

  /// Creates a [ProductModel] from a Firestore [DocumentSnapshot].
  factory ProductModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final json = doc.data() ?? {};
    return ProductModel(
      id: doc.id,
      businessId: json['businessId'] as String? ?? '',
      sku: json['sku'] as String?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdAt: json['createdAt'] is Timestamp 
          ? (json['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      updatedAt: json['updatedAt'] is Timestamp 
          ? (json['updatedAt'] as Timestamp).toDate() 
          : DateTime.now(),
      category: json['category'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? true,
      salesCount: json['salesCount'] as int? ?? 0,
      imageUrl: List<String>.from(json['imageUrls'] as List? ?? []),
      variants: (json['variants'] as List? ?? [])
          .map((v) => ProductVariantModel.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Creates a [ProductModel] from a [ProductEntity].
  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      businessId: entity.businessId,
      sku: entity.sku,
      name: entity.name,
      description: entity.description,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      category: entity.category,
      isAvailable: entity.isAvailable,
      salesCount: entity.salesCount,
      imageUrl: entity.imageUrl,
      variants: entity.variants
          .map(ProductVariantModel.fromEntity)
          .toList(),
    );
  }

  /// Converts the [ProductModel] to a JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'businessId': businessId,
    'sku': sku,
    'name': name,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'category': category,
    'isAvailable': isAvailable,
    'salesCount': salesCount,
    'imageUrls': imageUrl,
    'variants': variants
        .map((v) => ProductVariantModel.fromEntity(v).toJson())
        .toList(),
  };

  /// Converts the model to its base entity.
  ProductEntity toEntity() => ProductEntity(
    id: id,
    businessId: businessId,
    sku: sku,
    name: name,
    description: description,
    createdAt: createdAt,
    updatedAt: updatedAt,
    category: category,
    isAvailable: isAvailable,
    salesCount: salesCount,
    imageUrl: imageUrl,
    variants: variants,
  );
}
