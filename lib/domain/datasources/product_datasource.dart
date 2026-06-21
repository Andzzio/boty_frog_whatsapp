// ignore_for_file: one_member_abstracts

import 'package:boty_frog/domain/entities/product_entity.dart';

/// Datasource interface for retrieving product information.
abstract class ProductDatasource {
  /// Loads all products belonging to a specific business.
  Future<List<ProductEntity>> getProducts(String businessId);
}
