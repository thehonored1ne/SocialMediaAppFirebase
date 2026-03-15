import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:social_media_app/core/common/widgets/loading_view.dart';
import 'package:social_media_app/core/common/widgets/user_avatar.dart';
import 'package:social_media_app/core/constants/app_colors.dart';
import 'package:social_media_app/core/router/app_routes.dart';
import 'package:social_media_app/features/auth/application/auth_controller.dart';
import 'package:social_media_app/features/chat/application/chat_controller.dart';
import 'package:social_media_app/features/chat/domain/models/chat_model.dart';
import 'package:social_media_app/features/profile/application/profile_controller.dart';

final chatSearchProvider = StateProvider.autoDispose<String>((ref) => "");

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(chatsStreamProvider);
    final suggestedAsync = ref.watch(suggestedUsersProvider);
    final searchQuery = ref.watch(chatSearchProvider).toLowerCase();
    final currentUserId = ref.watch(authStateChangesProvider).value?.uid ?? "";

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Messages',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: AppColors.textPrimary, size: 30),
            onPressed: () {},
          )
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _SearchBar()),
          if (searchQuery.isEmpty) 
            SliverToBoxAdapter(
              child: _ActiveNowSection(
                suggestedAsync: suggestedAsync, 
                currentUserId: currentUserId,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          chatsAsync.when(
            data: (chats) {
              final filteredChats = chats.where((chat) {
                final otherUserId = chat.users.firstWhere((id) => id != currentUserId, orElse: () => "");
                final otherInfo = chat.usersInfo[otherUserId] ?? {};
                final name = (otherInfo['name'] ?? "").toString().toLowerCase();
                return name.contains(searchQuery);
              }).toList();

              if (filteredChats.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text('No conversations found', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _ChatTile(chat: filteredChats[index], currentUserId: currentUserId);
                  },
                  childCount: filteredChats.length,
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: LoadingView(),
            ),
            error: (err, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveNowSection extends StatelessWidget {
  final AsyncValue<List<dynamic>> suggestedAsync;
  final String currentUserId;

  const _ActiveNowSection({required this.suggestedAsync, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return suggestedAsync.when(
      data: (users) {
        final otherUsers = users.where((u) => u.uid != currentUserId).toList();
        if (otherUsers.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 100,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                ...ScrollConfiguration.of(context).dragDevices,
                PointerDeviceKind.mouse,
              },
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: otherUsers.length,
              itemBuilder: (context, index) {
                final user = otherUsers[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(
                    onTap: () => context.pushNamed(
                      AppRoutes.chat,
                      extra: {
                        'otherUserId': user.uid,
                        'otherUserName': user.username,
                        'otherUserImage': user.profileImage,
                      },
                    ),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            UserAvatar(username: user.username, imageUrl: user.profileImage, radius: 30),
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: AppColors.onlineStatus,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.background, width: 2),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 60,
                          child: Text(
                            user.username,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
      loading: () => const SizedBox(height: 100),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _SearchBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          onChanged: (value) => ref.read(chatSearchProvider.notifier).state = value.trim(),
          decoration: const InputDecoration(
            hintText: 'Search user...',
            hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            prefixIcon: Icon(Icons.search, color: AppColors.textSecondary, size: 22),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
        ),
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final ChatModel chat;
  final String currentUserId;

  const _ChatTile({required this.chat, required this.currentUserId});

  String _formatTime(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0) return "${diff.inDays}d";
    if (diff.inHours > 0) return "${diff.inHours}h";
    if (diff.inMinutes > 0) return "${diff.inMinutes}m";
    return "now";
  }

  @override
  Widget build(BuildContext context) {
    final otherUserId = chat.users.firstWhere((id) => id != currentUserId, orElse: () => "");
    final otherInfo = chat.usersInfo[otherUserId] ?? {};
    final String otherUserName = otherInfo['name'] ?? 'User';
    final String userImage = otherInfo['image'] ?? '';
    final bool isUnread = !chat.seenBy.contains(currentUserId);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: UserAvatar(username: otherUserName, imageUrl: userImage, radius: 28),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            otherUserName,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: isUnread ? FontWeight.w900 : FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            _formatTime(chat.timestamp),
            style: TextStyle(
              color: isUnread ? AppColors.primary : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              chat.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isUnread ? AppColors.textPrimary : AppColors.textSecondary,
                fontSize: 14,
                fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          if (isUnread)
            Container(
              margin: const EdgeInsets.only(left: 8),
              width: 10,
              height: 10,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            ),
        ],
      ),
      onTap: () => context.pushNamed(
        AppRoutes.chat,
        extra: {
          'otherUserId': otherUserId,
          'otherUserName': otherUserName,
          'otherUserImage': userImage,
        },
      ),
    );
  }
}
