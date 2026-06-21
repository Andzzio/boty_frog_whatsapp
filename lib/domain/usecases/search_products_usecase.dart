import 'package:boty_frog/domain/entities/product_entity.dart';
import 'package:boty_frog/domain/repos/product_repository.dart';

/// Usecase for searching products within a business catalog.
class SearchProductsUsecase {
  /// Constructs a [SearchProductsUsecase] with the given [ProductRepository].
  SearchProductsUsecase(this._repository);

  final ProductRepository _repository;

  /// Executes the product search logic.
  Future<List<ProductEntity>> call({
    required String businessId,
    required String query,
  }) async {
    return _repository.searchProducts(
      businessId: businessId,
      query: query,
    );
  }
}
