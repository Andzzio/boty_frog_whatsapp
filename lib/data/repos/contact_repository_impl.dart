import 'package:boty_frog/domain/datasources/contact_remote_datasource.dart';
import 'package:boty_frog/domain/entities/contact_entity.dart';
import 'package:boty_frog/domain/repos/contact_repository.dart';

/// ContactRepository Implementation.
class ContactRepositoryImpl implements ContactRepository {
  /// Constructor for [ContactRepositoryImpl]
  ContactRepositoryImpl(this._datasource);

  final ContactRemoteDatasource _datasource;

  @override
  Future<ContactEntity?> getContact(List<dynamic> contactsJson) async {
    final contact = await _datasource.getContact(contactsJson);
    return contact?.toEntity();
  }
}
