import 'package:boty_frog/data/models/conversation_model.dart';
import 'package:boty_frog/data/models/message_model.dart';
import 'package:boty_frog/domain/datasources/conversation_datasource.dart';
import 'package:boty_frog/domain/entities/contact_entity.dart';
import 'package:boty_frog/domain/entities/conversation_entity.dart';
import 'package:boty_frog/domain/entities/message_entity.dart';
import 'package:boty_frog/domain/entities/tenant_config_entity.dart';
import 'package:firebase_admin_sdk/firebase_admin_sdk.dart';
import 'package:google_cloud_firestore/google_cloud_firestore.dart';

/// Firestore implementation of [ConversationLocalDatasource].
class ConversationFirestoreDatasource implements ConversationLocalDatasource {
  /// Constructs a [ConversationFirestoreDatasource]
  /// with the given [FirebaseApp].
  ConversationFirestoreDatasource(this._app);
  final FirebaseApp _app;

  Firestore get _firestore => _app.firestore();

  @override
  Future<ConversationEntity?> getConversation({
    required ContactEntity contact,
    required TenantConfigEntity tenant,
  }) async {
    final docRef = _firestore
        .collection('businesses')
        .doc(tenant.businessId)
        .collection('conversations')
        .doc(contact.phoneId);

    final docSnap = await docRef.get();
    if (!docSnap.exists) return null;

    final messagesSnap = await docRef
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .get();

    final messages = messagesSnap.docs.map((doc) {
      return MessageModel.fromJson(doc.data(), id: doc.id).toEntity();
    }).toList();

    final conversationModel = ConversationModel.fromFirestore(
      docSnap.data()!,
      docSnap.id,
    );

    return conversationModel.copyWith(messages: messages);
  }

  @override
  Future<void> saveConversation({
    required ConversationEntity conversation,
    required TenantConfigEntity tenant,
  }) async {
    final model = ConversationModel(
      id: conversation.id,
      contact: conversation.contact,
      messages: conversation.messages,
      unreadCount: conversation.unreadCount,
      lastMessage: conversation.lastMessage,
      isBotActive: conversation.isBotActive,
    );

    await _firestore
        .collection('businesses')
        .doc(tenant.businessId)
        .collection('conversations')
        .doc(conversation.contact.phoneId)
        .set(model.toFirestore());
  }

  @override
  Future<void> addMessageInConversation({
    required String conversationId,
    required MessageEntity message,
    required TenantConfigEntity tenant,
  }) async {
    final model = MessageModel.fromEntity(message);
    final convRef = _firestore
        .collection('businesses')
        .doc(tenant.businessId)
        .collection('conversations')
        .doc(conversationId);

    final msgRef = convRef.collection('messages').doc();
    final updatedModel = MessageModel(
      id: msgRef.id,
      recipientId: model.recipientId,
      senderId: model.senderId,
      senderName: model.senderName,
      content: model.content,
      timestamp: model.timestamp,
      isRead: model.isRead,
      type: model.type,
      media: model.media,
      whatsappMessageId: model.id ?? model.whatsappMessageId,
    );

    await msgRef.set(updatedModel.toJson());
  }

  @override
  Future<void> updateMessageStatus({
    required String messageId,
    required String conversationId,
    required String status,
    required TenantConfigEntity tenant,
  }) async {
    final messagesRef = _firestore
        .collection('businesses')
        .doc(tenant.businessId)
        .collection('conversations')
        .doc(conversationId)
        .collection('messages');

    final querySnap = await messagesRef
        .where('whatsappMessageId', WhereFilter.equal, messageId)
        .get();

    if (querySnap.docs.isNotEmpty) {
      final docRef = querySnap.docs.first.ref;
      await docRef.update({'status': status});
    } else {
      final docRef = messagesRef.doc(messageId);
      final docSnap = await docRef.get();
      if (docSnap.exists) {
        await docRef.update({'status': status});
      }
    }
  }

  @override
  Future<void> associateWhatsappMessageId({
    required String crmMessageId,
    required String whatsappMessageId,
    required String conversationId,
    required TenantConfigEntity tenant,
  }) async {
    final messageRef = _firestore
        .collection('businesses')
        .doc(tenant.businessId)
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(crmMessageId);

    await messageRef.update({
      'whatsappMessageId': whatsappMessageId,
      'status': 'sent',
    });
  }
}
