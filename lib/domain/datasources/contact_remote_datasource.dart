import 'package:boty_frog/data/models/contact_model.dart';

/// Contract of [ContactRemoteDatasource]
// ignore: one_member_abstracts
abstract class ContactRemoteDatasource {
  /// Returns a [ContactModel] or null if does't exist.
  Future<ContactModel?> getContact(List<dynamic> contactsJson);
}
