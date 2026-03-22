import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:social_media_app/features/auth/application/auth_controller.dart';
import 'package:social_media_app/features/notification/data/repositories/firestore_notification_repository.dart';
import 'package:social_media_app/features/notification/domain/models/notification_model.dart';

part 'notification_controller.g.dart';

@riverpod
class NotificationFilter extends _$NotificationFilter {
  @override
  String build() => 'All';

  void setFilter(String filter) => state = filter;
}

@riverpod
Stream<List<NotificationModel>> notificationsStream(Ref ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return const Stream.empty();
  
  final filter = ref.watch(notificationFilterProvider);
  final stream = ref.watch(notificationRepositoryProvider).getNotifications(user.uid);

  if (filter == 'All') return stream;

  return stream.map((list) => list.where((n) {
        if (filter == 'Likes') return n.type == NotificationType.like;
        if (filter == 'Comments') return n.type == NotificationType.comment;
        if (filter == 'Follows') return n.type == NotificationType.follow;
        return true;
      }).toList());
}

@riverpod
class NotificationController extends _$NotificationController {
  @override
  FutureOr<void> build() {}

  Future<void> markAsRead(String notificationId) async {
    try {
      await ref.read(notificationRepositoryProvider).markAsRead(notificationId);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await ref.read(notificationRepositoryProvider).deleteNotification(notificationId);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> markAllAsRead() async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;

    try {
      await ref.read(notificationRepositoryProvider).markAllAsRead(user.uid);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
