import 'package:boty_frog/data/models/tenant_config_model.dart';
import 'package:boty_frog/domain/datasources/tenant_config_datasource.dart';
import 'package:boty_frog/domain/entities/tenant_config_entity.dart';
import 'package:firebase_admin_sdk/firebase_admin_sdk.dart';
import 'package:google_cloud_firestore/google_cloud_firestore.dart';

/// Firestore implementation of [TenantConfigDatasource].
class TenantConfigFirestoreDatasource implements TenantConfigDatasource {
  /// Constructs a [TenantConfigFirestoreDatasource]
  /// with the given [FirebaseApp].
  TenantConfigFirestoreDatasource(this._app);
  final FirebaseApp _app;

  Firestore get _firestore => _app.firestore();

  @override
  /// Loads all registered tenant configurations
  /// from the 'whatsapp_settings' collection.
  Future<List<TenantConfigEntity>> loadAllConfigs() async {
    final snapshot = await _firestore.collection('whatsapp_settings').get();
    return snapshot.docs.map((doc) {
      return TenantConfigModel.fromFirestore(doc.data(), doc.id);
    }).toList();
  }

  @override
  /// Loads a single tenant configuration from Firestore
  /// using the business document ID [businessId].
  Future<TenantConfigEntity?> getConfigByBusinessId(String businessId) async {
    final docSnap = await _firestore
        .collection('whatsapp_settings')
        .doc(businessId)
        .get();
    if (!docSnap.exists) return null;
    return TenantConfigModel.fromFirestore(docSnap.data()!, docSnap.id);
  }
}
