import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:social_media_app/core/error/failure.dart';
import 'package:social_media_app/features/chat/domain/models/chat_model.dart';
import 'package:social_media_app/features/chat/domain/models/message_model.dart';
import 'package:social_media_app/features/chat/domain/repositories/chat_repository.dart';

part 'firestore_chat_repository.g.dart';

@riverpod
ChatRepository chatRepository(Ref ref) {
  return FirestoreChatRepository();
}

class FirestoreChatRepository implements ChatRepository {
  final FirebaseFirestore _firestore;

  FirestoreChatRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<ChatModel>> getChats(String uid) {
    return _firestore
        .collection('chats')
        .where('users', arrayContains: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return ChatModel(
                chatId: doc.id,
                users: List<String>.from(data['users'] ?? []),
                lastMessage: data['lastMessage'] ?? '',
                timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
                seenBy: List<String>.from(data['seenBy'] ?? []),
                usersInfo: data['usersInfo'] ?? {},
              );
            }).toList());
  }

  @override
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return MessageModel(
                messageId: doc.id,
                senderId: data['senderId'] ?? '',
                text: data['text'] ?? '',
                timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
                isRead: data['isRead'] ?? false,
              );
            }).toList());
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String text,
    required Map<String, dynamic> usersInfo,
  }) async {
    try {
      final batch = _firestore.batch();

      // Create message
      final messageRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc();

      final messageData = {
        'senderId': senderId,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      };

      batch.set(messageRef, messageData);

      // Update/Create chat document
      final chatRef = _firestore.collection('chats').doc(chatId);
      batch.set(
        chatRef,
        {
          'users': [senderId, receiverId],
          'lastMessage': text,
          'timestamp': FieldValue.serverTimestamp(),
          'seenBy': [senderId],
          'usersInfo': usersInfo,
        },
        SetOptions(merge: true),
      );

      await batch.commit();
    } catch (e, stackTrace) {
      throw Failure(e.toString(), stackTrace);
    }
  }

  @override
  Future<void> markAsSeen(String chatId, String uid) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'seenBy': FieldValue.arrayUnion([uid]),
      });
    } catch (e, stackTrace) {
      throw Failure(e.toString(), stackTrace);
    }
  }
}
