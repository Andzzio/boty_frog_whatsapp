import 'package:boty_frog/domain/entities/contact_entity.dart';

/// Contract of [ContactRepository]
// ignore: one_member_abstracts
abstract class ContactRepository {
  /// Returns a [ContactEntity] or null if does't exist.
  Future<ContactEntity?> getContact(List<dynamic> contactsJson);
}
