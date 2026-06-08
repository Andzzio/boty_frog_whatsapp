import 'package:boty_frog/data/models/message_model.dart';
import 'package:boty_frog/domain/datasources/message_remote_datasource.dart';
import 'package:boty_frog/domain/entities/message_entity.dart';
import 'package:dio/dio.dart';
import 'package:dotenv/dotenv.dart';
import 'package:logging/logging.dart';

/// Implementation of the [MessageRemoteDatasource] interface.
class MessageWhatsappApiDatasource implements MessageRemoteDatasource {
  /// Constructs a [MessageWhatsappApiDatasource] with the given [Dio] instance
  /// and [DotEnv] instance.
  MessageWhatsappApiDatasource({required Dio dio, required DotEnv env})
    : _dio = dio,
      _env = env;

  final Dio _dio;
  final DotEnv _env;
  static final _logger = Logger('MessageWhatsappApiDatasource');

  String get _token => _env['WHATSAPP_API_TOKEN']!;
  String get _phoneId => _env['WHATSAPP_PHONE_ID']!;

  @override
  Future<MessageEntity> receiveMessage(Map<String, dynamic> messageData) async {
    return MessageModel.fromWhatsappJson(messageData);
  }

  @override
  Future<MessageEntity> sendMessage(MessageEntity message) async {
    final url = 'https://graph.facebook.com/v25.0/$_phoneId/messages';

    final messageModelToSend = MessageModel.fromEntity(message);

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        ),
        data: messageModelToSend.toWhatsappJson(),
      );

      final messages = response.data?['messages'] as List<dynamic>;
      final messageJson = messages[0] as Map<String, dynamic>;
      final messageId = messageJson['id'] as String;

      final messageEntity = messageModelToSend.toEntity().copyWith(
        id: messageId,
        timestamp: DateTime.now(),
      );

      return messageEntity;
    } on DioException catch (e) {
      _logger.severe('Failed to send message: ${e.message}', e);
      rethrow;
    }
  }
}
