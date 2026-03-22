import '../models/notification_model.dart';

abstract class NotificationRepository {
  Stream<List<NotificationModel>> getNotifications(String uid);
  Future<void> markAsRead(String notificationId);
  Future<void> deleteNotification(String notificationId);
  Future<void> markAllAsRead(String uid);
  Future<void> sendNotification(NotificationModel notification);
}
