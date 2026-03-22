import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:social_media_app/core/common/widgets/loading_view.dart';
import 'package:social_media_app/core/common/widgets/user_avatar.dart';
import 'package:social_media_app/core/constants/app_colors.dart';
import 'package:social_media_app/core/router/app_routes.dart';
import 'package:social_media_app/features/notification/application/notification_controller.dart';
import 'package:social_media_app/features/notification/domain/models/notification_model.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsStreamProvider);
    final selectedFilter = ref.watch(notificationFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Notifications',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded, color: AppColors.primary),
            onPressed: () => ref.read(notificationControllerProvider.notifier).markAllAsRead(),
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterSection(selectedFilter: selectedFilter),
          Expanded(
            child: notificationsAsync.when(
              data: (notifications) {
                if (notifications.isEmpty) {
                  return const _EmptyNotifications();
                }
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return Dismissible(
                      key: Key(notification.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: AppColors.error,
                        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        ref.read(notificationControllerProvider.notifier).deleteNotification(notification.id);
                      },
                      child: _NotificationTile(notification: notification),
                    );
                  },
                );
              },
              loading: () => const LoadingView(),
              error: (err, _) => Center(
                child: Text('Error: $err', style: const TextStyle(color: AppColors.error)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSection extends ConsumerWidget {
  final String selectedFilter;
  const _FilterSection({required this.selectedFilter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ['All', 'Likes', 'Comments', 'Follows'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  ref.read(notificationFilterProvider.notifier).setFilter(filter);
                }
              },
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final NotificationModel notification;
  const _NotificationTile({required this.notification});

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 7) return "${date.day}/${date.month}";
    if (diff.inDays >= 1) return "${diff.inDays}d";
    if (diff.inHours >= 1) return "${diff.inHours}h";
    if (diff.inMinutes >= 1) return "${diff.inMinutes}m";
    return "now";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: notification.isRead ? Colors.transparent : AppColors.textPrimary.withValues(alpha: 0.03),
      child: ListTile(
        onTap: () {
          ref.read(notificationControllerProvider.notifier).markAsRead(notification.id);
          if (notification.postId != null) {
             // Navigation to post detail could go here
          } else if (notification.type == NotificationType.follow) {
            context.pushNamed(AppRoutes.profile, pathParameters: {'uid': notification.senderId});
          }
        },
        leading: GestureDetector(
          onTap: () => context.pushNamed(AppRoutes.profile, pathParameters: {'uid': notification.senderId}),
          child: UserAvatar(
            username: notification.senderName,
            imageUrl: notification.senderImage,
            radius: 22,
          ),
        ),
        title: RichText(
          text: TextSpan(
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            children: [
              TextSpan(
                text: notification.senderName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' '),
              TextSpan(text: notification.text),
              TextSpan(
                text: '  ${_formatTime(notification.timestamp)}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
        trailing: notification.isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, size: 80, color: AppColors.textSecondary.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          const Text(
            'No notifications yet',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
