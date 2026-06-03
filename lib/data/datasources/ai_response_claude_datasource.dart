import 'package:boty_frog/data/constants/system_prompts.dart';
import 'package:boty_frog/data/models/ai_response_model.dart';
import 'package:boty_frog/domain/datasources/ai_response_remote_datasource.dart';
import 'package:boty_frog/domain/entities/conversation_entity.dart';
import 'package:boty_frog/domain/entities/message_entity.dart';
import 'package:dio/dio.dart';
import 'package:dotenv/dotenv.dart';
import 'package:logging/logging.dart';

/// Datasource for AI Response API Calls using Claude API
class AiResponseClaudeDatasource implements AiResponseRemoteDatasource {
  /// Constructs an [AiResponseClaudeDatasource] with the given Dio client and
  /// environment variables.
  AiResponseClaudeDatasource({required Dio dio, required DotEnv env})
    : _dio = dio,
      _env = env;

  final Dio _dio;
  final DotEnv _env;
  static final _logger = Logger('AiResponseClaudeDatasource');

  String get _systemPrompt => SystemPrompts.wspBotSystemPrompt;
  String get _token => _env['API_KEY'] ?? '';
  String get _url => 'https://api.anthropic.com/v1/messages';
  String get _model => 'claude-haiku-4-5';

  @override
  Future<AiResponseModel> generateHistoryBasedResponse(
    ConversationEntity conversation,
  ) async {
    final phoneId = _env['WHATSAPP_PHONE_ID'];
    final messages = conversation.messages
        .map(
          (msg) => {
            'role': msg.senderId == phoneId ? 'assistant' : 'user',
            'content': msg.content,
          },
        )
        .toList();
    final contactName = conversation.contact.name;
    messages.insert(0, {
      'role': 'user',
      'content': 'Mi nombre es $contactName',
    });
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _url,
        options: Options(
          headers: {
            'x-api-key': _token,
            'anthropic-version': '2023-06-01',
            'content-type': 'application/json',
          },
        ),
        data: {
          'model': _model,
          'max_tokens': 1024,
          'cache_control': {'type': 'ephemeral'},
          'system': _systemPrompt,
          'messages': messages,
        },
      );

      final contents = response.data?['content'] as List<dynamic>;
      final content = contents[0] as Map<String, dynamic>;
      final text = content['text'] as String;

      _logger.info('AI response generated: $text');

      return AiResponseModel(responseText: text);
    } on DioException catch (e) {
      _logger.severe('Failed to generate simple response: ${e.message}', e);
      rethrow;
    }
  }

  @override
  Future<AiResponseModel> generateSimpleResponse(MessageEntity message) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _url,
        options: Options(
          headers: {
            'x-api-key': _token,
            'anthropic-version': '2023-06-01',
            'content-type': 'application/json',
          },
        ),
        data: {
          'model': _model,
          'max_tokens': 1024,
          'cache_control': {'type': 'ephemeral'},
          'system': _systemPrompt,
          'messages': [
            {
              'role': 'user',
              'content': message.content,
            },
          ],
        },
      );

      final contents = response.data?['content'] as List<dynamic>;
      final content = contents[0] as Map<String, dynamic>;
      final text = content['text'] as String;

      _logger.info('AI response generated: $text');

      return AiResponseModel(responseText: text);
    } on DioException catch (e) {
      _logger.severe('Failed to generate simple response: ${e.message}', e);
      rethrow;
    }
  }
}
