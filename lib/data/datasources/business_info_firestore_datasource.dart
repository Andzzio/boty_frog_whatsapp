import 'package:boty_frog/data/models/business_info_model.dart';
import 'package:boty_frog/data/models/shipping_zone_model.dart';
import 'package:boty_frog/domain/datasources/business_info_datasource.dart';
import 'package:boty_frog/domain/entities/business_info_entity.dart';
import 'package:firebase_admin_sdk/firebase_admin_sdk.dart';

/// Firestore implementation of [BusinessInfoDatasource].
class BusinessInfoFirestoreDatasource implements BusinessInfoDatasource {
  /// Constructs a [BusinessInfoFirestoreDatasource] instance.
  BusinessInfoFirestoreDatasource(this._app);

  final FirebaseApp _app;

  @override
  Future<BusinessInfoEntity> getBusinessInfo(String businessId) async {
    final firestore = _app.firestore();
    final businessDoc = await firestore
        .collection('businesses')
        .doc(businessId)
        .get();

    final businessData = businessDoc.data() ?? {};

    final shippingZonesSnapshot = await firestore
        .collection('businesses')
        .doc(businessId)
        .collection('shipping_zones')
        .get();

    final zones = shippingZonesSnapshot.docs.map((doc) {
      return ShippingZoneModel.fromJson(doc.data(), doc.id);
    }).toList();

    return BusinessInfoModel.fromFirestore(businessData, zones);
  }

  @override
  Future<void> updateBusinessInfo(
    String businessId,
    BusinessInfoEntity info,
  ) {
    throw UnimplementedError();
  }
}
