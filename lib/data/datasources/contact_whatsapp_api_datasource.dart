import 'package:boty_frog/data/models/contact_model.dart';
import 'package:boty_frog/domain/datasources/contact_remote_datasource.dart';

/// ContactDatasource Implementation for Whatsapp API
class ContactWhatsappApiDatasource implements ContactRemoteDatasource {
  @override
  Future<ContactModel?> getContact(List<dynamic> contactsJson) async {
    return ContactModel.fromWhatsappJson(contactsJson);
  }
}
