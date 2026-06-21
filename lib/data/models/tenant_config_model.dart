import 'package:boty_frog/domain/entities/tenant_config_entity.dart';

/// Data model representing a tenant configuration,
/// extending [TenantConfigEntity].
class TenantConfigModel extends TenantConfigEntity {
  /// Constructs a [TenantConfigModel] instance.
  TenantConfigModel({
    required super.businessId,
    required super.phoneId,
    required super.apiToken,
    required super.verifyToken,
    required super.aiApiKey,
    required super.brandName,
    required super.catalogUrl,
    required super.businessType,
    required super.toneStyle,
    required super.botName,
  });

  /// Maps a Firestore document data [json] and
  /// document ID [docId] to a [TenantConfigModel].
  factory TenantConfigModel.fromFirestore(
    Map<String, dynamic> json,
    String docId,
  ) {
    return TenantConfigModel(
      businessId: docId,
      phoneId: json['phoneId'] as String? ?? '',
      apiToken: json['apiToken'] as String? ?? '',
      verifyToken: json['verifyToken'] as String? ?? '',
      aiApiKey: json['aiApiKey'] as String? ?? '',
      brandName: json['brandName'] as String? ?? '',
      catalogUrl: json['catalogUrl'] as String? ?? '',
      businessType: json['businessType'] as String? ?? '',
      toneStyle: json['toneStyle'] as String? ?? '',
      botName: json['botName'] as String? ?? '',
    );
  }

  /// Converts this model instance into a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'phoneId': phoneId,
      'apiToken': apiToken,
      'verifyToken': verifyToken,
      'aiApiKey': aiApiKey,
      'brandName': brandName,
      'catalogUrl': catalogUrl,
      'businessType': businessType,
      'toneStyle': toneStyle,
      'botName': botName,
    };
  }
}
