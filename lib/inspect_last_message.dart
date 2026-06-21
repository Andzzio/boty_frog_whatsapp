import 'dart:io';
import 'package:dotenv/dotenv.dart';
import 'package:firebase_admin_sdk/firebase_admin_sdk.dart' as admin;

void main() async {
  final env = DotEnv()..load();
  final app = admin.FirebaseApp.initializeApp(
    options: admin.AppOptions(
      credential: admin.Credential.fromServiceAccount(
        File(env['GOOGLE_APPLICATION_CREDENTIALS']!),
      ),
      projectId: env['PROJECT_ID'],
    ),
  );

  final firestore = app.firestore();

  try {
    final conversations = await firestore
        .collection('businesses')
        .doc('shurumba')
        .collection('conversations')
        .doc('51924471992')
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(3)
        .get();

    if (conversations.docs.isEmpty) {
      stdout.writeln('No hay mensajes.');
      return;
    }

    stdout.writeln('Últimos mensajes de shurumba:');
    for (final doc in conversations.docs) {
      final msg = doc.data();
      stdout.writeln(
        ' - Msg ID: ${doc.id}, Tipo: ${msg['type']}, '
        'Contenido: "${msg['content']}", mediaUrl: "${msg['mediaUrl']}"',
      );
    }
  } catch (e) {
    stdout.writeln('Error al inspeccionar Firestore: $e');
  } finally {
    await app.close();
  }
}
