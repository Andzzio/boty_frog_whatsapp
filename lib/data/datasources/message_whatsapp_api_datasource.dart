import 'dart:convert';
import 'package:boty_frog/data/models/message_model.dart';
import 'package:boty_frog/domain/datasources/message_remote_datasource.dart';
import 'package:boty_frog/domain/entities/message_entity.dart';
import 'package:boty_frog/domain/entities/tenant_config_entity.dart';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

/// Meta Graph API implementation of [MessageRemoteDatasource].
class MessageWhatsappApiDatasource implements MessageRemoteDatasource {
  /// Constructs a [MessageWhatsappApiDatasource] with the given [Dio] client.
  MessageWhatsappApiDatasource({required Dio dio}) : _dio = dio;

  final Dio _dio;
  static final _logger = Logger('MessageWhatsappApiDatasource');

  @override
  Future<MessageEntity> receiveMessage(Map<String, dynamic> messageData) async {
    return MessageModel.fromWhatsappJson(messageData);
  }

  @override
  Future<MessageEntity> sendMessage(
    MessageEntity message,
    TenantConfigEntity tenant,
  ) async {
    final url = 'https://graph.facebook.com/v25.0/${tenant.phoneId}/messages';

    final messageModelToSend = MessageModel.fromEntity(message);

    try {
      final response = await _dio.post<dynamic>(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${tenant.apiToken}',
          },
        ),
        data: messageModelToSend.toWhatsappJson(),
      );

      dynamic data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }

      if (data is! Map<String, dynamic>) {
        throw Exception('La respuesta de WhatsApp no es un JSON Map: $data');
      }

      final messages = data['messages'] as List<dynamic>;
      final messageJson = messages[0] as Map<String, dynamic>;
      final messageId = messageJson['id'] as String;

      final messageEntity = messageModelToSend.toEntity().copyWith(
        id: messageId,
        timestamp: DateTime.now(),
      );

      return messageEntity;
    } on DioException catch (e) {
      _logger.severe(
        'Failed to send message: ${e.message}. '
        'Response: ${e.response?.data}',
        e,
      );
      rethrow;
    } catch (e, stackTrace) {
      _logger.severe('Unexpected error sending message: $e', e, stackTrace);
      rethrow;
    }
  }
}
