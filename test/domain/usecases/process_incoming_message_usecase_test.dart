import 'package:boty_frog/core/debounce_manager.dart';
import 'package:boty_frog/domain/entities/contact_entity.dart';
import 'package:boty_frog/domain/entities/conversation_entity.dart';
import 'package:boty_frog/domain/entities/message_entity.dart';
import 'package:boty_frog/domain/entities/tenant_config_entity.dart';
import 'package:boty_frog/domain/usecases/add_message_in_conversation_usecase.dart';
import 'package:boty_frog/domain/usecases/generate_history_based_response.dart';
import 'package:boty_frog/domain/usecases/get_contact_usecase.dart';
import 'package:boty_frog/domain/usecases/get_or_create_conversation_usecase.dart';
import 'package:boty_frog/domain/usecases/process_incoming_message_usecase.dart';
import 'package:boty_frog/domain/usecases/receive_message_usecase.dart';
import 'package:boty_frog/domain/usecases/save_conversation_usecase.dart';
import 'package:boty_frog/domain/usecases/send_message_usecase.dart';
import 'package:boty_frog/domain/usecases/upload_message_media_usecase.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockReceiveMessageUsecase extends Mock
    implements ReceiveMessageUsecase {}

class MockGetContactUsecase extends Mock implements GetContactUsecase {}

class MockGetOrCreateConversationUsecase extends Mock
    implements GetOrCreateConversationUsecase {}

class MockSaveConversationUsecase extends Mock
    implements SaveConversationUsecase {}

class MockGenerateHistoryBasedResponse extends Mock
    implements GenerateHistoryBasedResponse {}

class MockSendMessageUsecase extends Mock implements SendMessageUsecase {}

class MockAddMessageInConversationUsecase extends Mock
    implements AddMessageInConversationUsecase {}

class MockUploadMessageMediaUsecase extends Mock
    implements UploadMessageMediaUsecase {}

void main() {
  late ProcessIncomingMessageUsecase usecase;
  late MockReceiveMessageUsecase mockReceiveMessage;
  late MockGetContactUsecase mockGetContact;
  late MockGetOrCreateConversationUsecase mockGetOrCreateConversation;
  late MockSaveConversationUsecase mockSaveConversation;
  late MockGenerateHistoryBasedResponse mockGenerateHistoryBasedResponse;
  late MockSendMessageUsecase mockSendMessage;
  late MockAddMessageInConversationUsecase mockAddMessageInConversation;
  late MockUploadMessageMediaUsecase mockUploadMessageMedia;

  final tenant = TenantConfigEntity(
    businessId: 'biz_123',
    phoneId: 'phone_123',
    apiToken: 'token_123',
    verifyToken: 'vtoken_123',
    aiApiKey: 'ai_123',
    brandName: 'brand_123',
    catalogUrl: 'cat_123',
    businessType: 'type_123',
    toneStyle: 'tone_123',
    botName: 'bot_123',
  );

  final contact = ContactEntity(name: 'André', phoneId: 'user_123');

  final receivedMessage = MessageEntity(
    id: 'msg_123',
    recipientId: 'phone_123',
    senderId: 'user_123',
    senderName: 'André',
    content: 'Hola',
  );

  final botReply = MessageEntity(
    id: 'reply_123',
    recipientId: 'user_123',
    senderId: 'phone_123',
    senderName: 'bot_123',
    content: 'Hola André, ¿en qué te ayudo?',
  );

  final initialConversation = ConversationEntity(
    contact: contact,
    id: 'user_123',
    unreadCount: 0,
  );

  setUpAll(() {
    registerFallbackValue(tenant);
    registerFallbackValue(contact);
    registerFallbackValue(receivedMessage);
    registerFallbackValue(initialConversation);
  });

  setUp(() {
    mockReceiveMessage = MockReceiveMessageUsecase();
    mockGetContact = MockGetContactUsecase();
    mockGetOrCreateConversation = MockGetOrCreateConversationUsecase();
    mockSaveConversation = MockSaveConversationUsecase();
    mockGenerateHistoryBasedResponse = MockGenerateHistoryBasedResponse();
    mockSendMessage = MockSendMessageUsecase();
    mockAddMessageInConversation = MockAddMessageInConversationUsecase();
    mockUploadMessageMedia = MockUploadMessageMediaUsecase();

    usecase = ProcessIncomingMessageUsecase(
      receiveMessage: mockReceiveMessage,
      getContact: mockGetContact,
      getOrCreateConversation: mockGetOrCreateConversation,
      saveConversation: mockSaveConversation,
      generatedhistoryBasedResponse: mockGenerateHistoryBasedResponse,
      sendMessage: mockSendMessage,
      addMessageInConversation: mockAddMessageInConversation,
      uploadMessageMedia: mockUploadMessageMedia,
      debounceDuration: const Duration(milliseconds: 50),
    );

    DebounceManager.instance.clear();
  });

  test(
    'saves message immediately but delays IA response & sending',
    () async {
      when(() => mockReceiveMessage(any()))
          .thenAnswer((_) async => receivedMessage);
      when(() => mockGetContact(any())).thenAnswer((_) async => contact);
      when(() => mockGetOrCreateConversation(
            contact: any(named: 'contact'),
            tenant: any(named: 'tenant'),
          )).thenAnswer((_) async => initialConversation);

      when(() => mockAddMessageInConversation(
            conversationId: any(named: 'conversationId'),
            message: any(named: 'message'),
            tenant: any(named: 'tenant'),
          )).thenAnswer((_) async => {});

      when(() => mockGenerateHistoryBasedResponse(any(), any()))
          .thenAnswer((_) async => botReply);

      when(() => mockSendMessage(any(), any()))
          .thenAnswer((_) async => botReply);

      when(() => mockSaveConversation(
            conversation: any(named: 'conversation'),
            tenant: any(named: 'tenant'),
          )).thenAnswer((_) async => {});

      final result = await usecase(
        messageData: <String, dynamic>{'some': 'data'},
        contactsJson: <dynamic>[],
        tenant: tenant,
      );

      expect(result, isTrue);

      verify(() => mockAddMessageInConversation(
            conversationId: 'user_123',
            message: receivedMessage,
            tenant: tenant,
          )).called(1);

      verifyNever(() => mockGenerateHistoryBasedResponse(any(), any()));
      verifyNever(() => mockSendMessage(any(), any()));

      await Future<void>.delayed(const Duration(milliseconds: 100));

      verify(() => mockGenerateHistoryBasedResponse(any(), any())).called(1);
      verify(() => mockSendMessage(botReply, tenant)).called(1);
      verify(() => mockSaveConversation(
            conversation: any(named: 'conversation'),
            tenant: tenant,
          )).called(1);
    },
  );

  test(
    'deactivates bot when the message is a checkout order summary',
    () async {
      final orderMessage = MessageEntity(
        id: 'msg_order_123',
        recipientId: 'phone_123',
        senderId: 'user_123',
        senderName: 'André',
        content: '🛒 *Nuevo Pedido - Zara*\nProductos:\n1. Polo L',
      );

      final mockConversation = ConversationEntity(
        contact: contact,
        id: 'user_123',
        unreadCount: 0,
      );

      when(() => mockReceiveMessage(any()))
          .thenAnswer((_) async => orderMessage);
      when(() => mockGetContact(any())).thenAnswer((_) async => contact);
      when(() => mockGetOrCreateConversation(
            contact: any(named: 'contact'),
            tenant: any(named: 'tenant'),
          )).thenAnswer((_) async => mockConversation);

      when(() => mockAddMessageInConversation(
            conversationId: any(named: 'conversationId'),
            message: any(named: 'message'),
            tenant: any(named: 'tenant'),
          )).thenAnswer((_) async => {});

      when(() => mockGenerateHistoryBasedResponse(any(), any()))
          .thenAnswer((_) async => botReply);

      when(() => mockSendMessage(any(), any()))
          .thenAnswer((_) async => botReply);

      ConversationEntity? savedConversation;
      when(() => mockSaveConversation(
            conversation: any(named: 'conversation'),
            tenant: any(named: 'tenant'),
          )).thenAnswer((invocation) async {
        savedConversation =
            invocation.namedArguments[#conversation] as ConversationEntity?;
      });

      final result = await usecase(
        messageData: <String, dynamic>{'some': 'data'},
        contactsJson: <dynamic>[],
        tenant: tenant,
      );

      expect(result, isTrue);

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(savedConversation, isNotNull);
      expect(savedConversation!.isBotActive, isFalse);
    },
  );
}
