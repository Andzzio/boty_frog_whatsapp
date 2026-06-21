// ignore_for_file: one_member_abstracts

import 'package:boty_frog/domain/entities/product_entity.dart';

/// Repository interface for product operations.
abstract class ProductRepository {
  /// Searches for products belonging to a business matching a query.
  Future<List<ProductEntity>> searchProducts({
    required String businessId,
    required String query,
  });
}
