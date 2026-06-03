import 'package:boty_frog/domain/entities/contact_entity.dart';

/// Model for [ContactEntity]
class ContactModel extends ContactEntity {
  /// Constructor for ContactModel, receive the name and the phoneId.
  ContactModel({required super.name, required super.phoneId});

  /// Constructor of [ContactModel] from WhatsappJson
  factory ContactModel.fromWhatsappJson(List<dynamic> contactsJson) {
    final contact = contactsJson[0] as Map<String, dynamic>;
    final phoneId = contact['wa_id'] as String;
    final profile = contact['profile'] as Map<String, dynamic>;
    final name = profile['name'] as String;

    return ContactModel(name: name, phoneId: phoneId);
  }

  /// Transform to entity.
  ContactEntity toEntity() {
    return ContactEntity(name: name, phoneId: phoneId);
  }
}
