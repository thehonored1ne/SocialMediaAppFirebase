import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:social_media_app/core/constants/app_constants.dart';
import 'package:social_media_app/features/notification/domain/models/notification_model.dart';
import 'package:social_media_app/features/notification/domain/repositories/notification_repository.dart';

part 'firestore_notification_repository.g.dart';

@riverpod
NotificationRepository notificationRepository(Ref ref) {
  return FirestoreNotificationRepository();
}

class FirestoreNotificationRepository implements NotificationRepository {
  final FirebaseFirestore _db;

  FirestoreNotificationRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  NotificationModel _mapToNotificationModel(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderImage: data['senderImage'] ?? '',
      receiverId: data['receiverId'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => NotificationType.like,
      ),
      postId: data['postId'],
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
    );
  }

  @override
  Stream<List<NotificationModel>> getNotifications(String uid) {
    return _db
        .collection(AppConstants.notificationsCollection)
        .where('receiverId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(_mapToNotificationModel).toList());
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _db
        .collection(AppConstants.notificationsCollection)
        .doc(notificationId)
        .update({'isRead': true});
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    await _db
        .collection(AppConstants.notificationsCollection)
        .doc(notificationId)
        .delete();
  }

  @override
  Future<void> markAllAsRead(String uid) async {
    final batch = _db.batch();
    final querySnapshot = await _db
        .collection(AppConstants.notificationsCollection)
        .where('receiverId', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in querySnapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  @override
  Future<void> sendNotification(NotificationModel notification) async {
    await _db.collection(AppConstants.notificationsCollection).add({
      'senderId': notification.senderId,
      'senderName': notification.senderName,
      'senderImage': notification.senderImage,
      'receiverId': notification.receiverId,
      'type': notification.type.name,
      'postId': notification.postId,
      'text': notification.text,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }
}
