import 'package:boty_frog/data/models/product_model.dart';
import 'package:boty_frog/domain/datasources/product_datasource.dart';
import 'package:boty_frog/domain/entities/product_entity.dart';
import 'package:firebase_admin_sdk/firebase_admin_sdk.dart';
import 'package:google_cloud_firestore/google_cloud_firestore.dart';

/// Firestore-backed implementation of [ProductDatasource].
class ProductFirestoreDatasource implements ProductDatasource {
  /// Constructs a [ProductFirestoreDatasource] with the given [FirebaseApp].
  ProductFirestoreDatasource(this._app);

  final FirebaseApp _app;

  /// Gets the Firestore instance associated with the app.
  Firestore get _firestore => _app.firestore();

  @override
  Future<List<ProductEntity>> getProducts(String businessId) async {
    final snapshot = await _firestore
        .collection('products')
        .where('businessId', WhereFilter.equal, businessId)
        .get();

    return snapshot.docs.map((doc) {
      return ProductModel.fromFirestore(doc).toEntity();
    }).toList();
  }
}
