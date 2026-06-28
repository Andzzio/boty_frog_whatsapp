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

    final rawDelivery = businessData['deliveryMethods'] as List? ?? [];
    final zones = rawDelivery.map((doc) {
      final map = (doc as Map).cast<String, dynamic>();
      return ShippingZoneModel.fromJson(map, map['name'] as String? ?? '');
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
