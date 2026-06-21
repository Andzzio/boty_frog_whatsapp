import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_admin_sdk/firebase_admin_sdk.dart';
import 'package:google_cloud_storage/google_cloud_storage.dart' as gcs;

/// Usecase to upload message media (images) downloaded from Meta Graph
/// to Firebase Storage and retrieve the public download URL.
class UploadMessageMediaUsecase {
  /// Constructs an [UploadMessageMediaUsecase] with the required dependencies.
  UploadMessageMediaUsecase({
    required FirebaseApp firebaseApp,
    required Dio dio,
  })  : _firebaseApp = firebaseApp,
        _dio = dio;

  final FirebaseApp _firebaseApp;
  final Dio _dio;

  /// Downloads media from Meta Graph API, uploads it to Firebase Storage,
  /// and returns the public download URL.
  Future<String> call({
    required String mediaId,
    required String apiToken,
    required String businessId,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'https://graph.facebook.com/v20.0/$mediaId',
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiToken',
        },
      ),
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Failed to get media metadata from WhatsApp API');
    }

    final mimeType = data['mime_type'] as String? ?? 'application/octet-stream';
    final baseMime = mimeType.split(';').first.trim().toLowerCase();
    final extension = _deduceExtension(baseMime);

    final downloadUrl = data['url'] as String?;
    if (downloadUrl == null || downloadUrl.isEmpty) {
      throw Exception('Media download URL is empty or null');
    }

    final fileResponse = await _dio.get<List<int>>(
      downloadUrl,
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiToken',
        },
        responseType: ResponseType.bytes,
      ),
    );

    final bytes = fileResponse.data;
    if (bytes == null || bytes.isEmpty) {
      throw Exception('Failed to download media bytes');
    }

    final client = await _firebaseApp.client;
    final storage = gcs.Storage(
      client: client,
      projectId: _firebaseApp.options.projectId,
    );
    const bucketName = 'catalogo-virtual-app.firebasestorage.app';
    final path = 'tenants/$businessId/media/$mediaId$extension';

    await storage.uploadObject(
      bucketName,
      path,
      bytes,
      metadata: gcs.ObjectMetadata(contentType: baseMime),
    );

    final encodedName = Uri.encodeComponent(path);
    final uri = Uri.parse(
      'https://firebasestorage.googleapis.com/v0/b/$bucketName/o/$encodedName',
    );
    final responseMetadata = await client.get(uri);

    if (responseMetadata.statusCode != 200) {
      throw Exception(
        'Failed to get download token. Status: ${responseMetadata.statusCode}',
      );
    }

    final metadataJson =
        jsonDecode(responseMetadata.body) as Map<String, dynamic>;
    final downloadTokens = metadataJson['downloadTokens'] as String?;

    if (downloadTokens == null || downloadTokens.isEmpty) {
      throw Exception('No download token available on uploaded object');
    }

    final token = downloadTokens.split(',').first;
    return 'https://firebasestorage.googleapis.com/v0/b/$bucketName/o/$encodedName?alt=media&token=$token';
  }

  String _deduceExtension(String baseMime) {
    if (baseMime == 'image/jpeg') {
      return '.jpg';
    } else if (baseMime == 'image/png') {
      return '.png';
    } else if (baseMime == 'image/webp') {
      return '.webp';
    } else if (baseMime == 'image/gif') {
      return '.gif';
    } else if (baseMime == 'audio/ogg' || baseMime == 'audio/ogg; codecs=opus') {
      return '.ogg';
    } else if (baseMime == 'audio/mpeg' || baseMime == 'audio/mp3') {
      return '.mp3';
    } else if (baseMime.startsWith('audio/')) {
      final sub = baseMime.substring(6);
      return '.$sub';
    } else if (baseMime == 'video/mp4') {
      return '.mp4';
    } else if (baseMime.startsWith('video/')) {
      final sub = baseMime.substring(6);
      return '.$sub';
    } else if (baseMime == 'application/pdf') {
      return '.pdf';
    } else if (baseMime == 'application/msword') {
      return '.doc';
    } else if (baseMime == 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') {
      return '.docx';
    } else if (baseMime == 'application/vnd.ms-excel') {
      return '.xls';
    } else if (baseMime == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') {
      return '.xlsx';
    } else if (baseMime == 'text/plain') {
      return '.txt';
    }
    final parts = baseMime.split('/');
    if (parts.length == 2) {
      return '.${parts[1]}';
    }
    return '.bin';
  }
}
