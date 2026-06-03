import 'package:boty_frog/domain/entities/contact_entity.dart';
import 'package:boty_frog/domain/repos/contact_repository.dart';

/// Get Contact Usecase
class GetContactUsecase {
  /// Constructor of [GetContactUsecase]
  GetContactUsecase(this._repo);

  final ContactRepository _repo;

  /// Call [GetContactUsecase]
  Future<ContactEntity?> call(List<dynamic> contactsJson) async {
    return _repo.getContact(contactsJson);
  }
}
