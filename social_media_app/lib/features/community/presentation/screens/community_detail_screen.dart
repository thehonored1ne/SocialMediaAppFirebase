import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:social_media_app/core/constants/app_colors.dart';
import 'package:social_media_app/core/constants/app_constants.dart';
import 'package:social_media_app/core/router/app_routes.dart';
import 'package:social_media_app/core/utils/snackbar_utils.dart';
import 'package:social_media_app/features/auth/application/auth_controller.dart';
import 'package:social_media_app/features/community/domain/models/community_model.dart';
import 'package:social_media_app/features/community/application/community_controller.dart';
import 'package:social_media_app/features/posts/presentation/widgets/post_card.dart';
import 'package:social_media_app/core/common/widgets/user_avatar.dart';

class CommunityDetailScreen extends ConsumerWidget {
  final String communityId;
  const CommunityDetailScreen({super.key, required this.communityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communityAsync = ref.watch(communityProvider(communityId));
    final currentUserId = ref.watch(authStateChangesProvider).value?.uid;

    return communityAsync.when(
      data: (community) {
        final bool isMember = community.members.contains(currentUserId);
        final bool isAdmin = community.adminId == currentUserId;
        final bool isPending = community.pendingRequests.contains(currentUserId);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
              onPressed: () => context.pop(),
            ),
            title: Text(
              community.name,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            actions: [
              if (isMember)
                IconButton(
                  icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
                  onPressed: () => _showCommunityMenu(context, ref, community, isAdmin),
                )
              else
                _JoinButton(
                  isPending: isPending,
                  onPressed: () => ref.read(communityControllerProvider.notifier).requestToJoin(communityId),
                ),
            ],
          ),
          body: CustomScrollView(
            slivers: [
              _CommunityHeader(community: community),
              if (isMember) ...[
                _PostActionCard(communityId: communityId),
                _CommunityFeed(communityId: communityId),
              ] else
                const _PrivateState(),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  void _showCommunityMenu(BuildContext context, WidgetRef ref, CommunityModel community, bool isAdmin) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.textTertiary, borderRadius: BorderRadius.circular(2)),
            ),
            if (isAdmin)
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: AppColors.textPrimary),
                title: const Text('Edit Community Info', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () => context.pushNamed(AppRoutes.editCommunity, extra: community),
              ),
            ListTile(
              leading: Badge(
                label: Text(community.pendingRequests.length.toString()),
                isLabelVisible: isAdmin && community.pendingRequests.isNotEmpty,
                child: const Icon(Icons.people_outline, color: AppColors.textPrimary),
              ),
              title: const Text('View Members', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                context.pop();
                _showPeopleSheet(context, communityId, isAdmin);
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
              title: const Text('Leave Community', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                context.pop();
                _handleLeave(context, ref, isAdmin, community.members.length);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLeave(BuildContext context, WidgetRef ref, bool isAdmin, int memberCount) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(isAdmin ? 'Leave and Delegate?' : 'Leave Community?'),
        content: Text(isAdmin 
          ? (memberCount > 1 
              ? 'You are the admin. Leaving will transfer admin status to another member.' 
              : 'You are the last member. Leaving will delete this community.')
          : 'Are you sure you want to leave this community?'),
        actions: [
          TextButton(onPressed: () => context.pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => context.pop(true), 
            child: Text('Leave', style: TextStyle(color: isAdmin ? Colors.redAccent : AppColors.primary)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(communityControllerProvider.notifier).leaveCommunity(communityId);
      if (context.mounted) {
        context.pop();
        SnackBarUtils.showSuccess(context, 'You left the community');
      }
    }
  }

  void _showPeopleSheet(BuildContext context, String id, bool isAdmin) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PeopleSheet(communityId: id, isAdmin: isAdmin),
    );
  }
}

class _JoinButton extends StatelessWidget {
  final bool isPending;
  final VoidCallback onPressed;

  const _JoinButton({required this.isPending, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isPending ? null : onPressed,
      child: Text(
        isPending ? 'Pending...' : 'Join',
        style: TextStyle(
          color: isPending ? AppColors.textTertiary : AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _CommunityHeader extends StatelessWidget {
  final CommunityModel community;
  const _CommunityHeader({required this.community});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.network(
                      community.communityImage.isNotEmpty 
                          ? community.communityImage 
                          : 'https://loremflickr.com/200/200/abstract',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.group, size: 40, color: AppColors.textTertiary),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${community.members.length} Members', 
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        community.description, 
                        style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Community Feed', 
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostActionCard extends StatelessWidget {
  final String communityId;
  const _PostActionCard({required this.communityId});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: AppConstants.defaultPadding),
        child: GestureDetector(
          onTap: () => context.pushNamed(AppRoutes.createPost, extra: communityId),
          child: Container(
            padding: const EdgeInsetsDirectional.all(12),
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(color: AppColors.textPrimary.withValues(alpha: 0.1)),
            ),
            child: const Row(
              children: [
                Icon(Icons.edit_note, color: AppColors.textSecondary),
                SizedBox(width: 12),
                Text('Post something in this community...', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CommunityFeed extends ConsumerWidget {
  final String communityId;
  const _CommunityFeed({required this.communityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(communityPostsProvider(communityId));

    return postsAsync.when(
      data: (posts) {
        if (posts.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text('No posts yet.', style: TextStyle(color: AppColors.textTertiary)),
            ),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => PostCard(post: posts[index]),
            childCount: posts.length,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
      error: (err, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
    );
  }
}

class _PrivateState extends StatelessWidget {
  const _PrivateState();

  @override
  Widget build(BuildContext context) {
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: AppColors.textTertiary),
            SizedBox(height: 16),
            Text(
              'This community is private.', 
              style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
            ),
            Text(
              'Join to see the feed.', 
              style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeopleSheet extends ConsumerWidget {
  final String communityId;
  final bool isAdmin;

  const _PeopleSheet({required this.communityId, required this.isAdmin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communityAsync = ref.watch(communityProvider(communityId));

    return communityAsync.when(
      data: (community) => DefaultTabController(
        length: isAdmin ? 2 : 1,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 12), 
                width: 40, 
                height: 4, 
                decoration: BoxDecoration(color: AppColors.textTertiary, borderRadius: BorderRadius.circular(2)),
              ),
              if (isAdmin)
                const TabBar(
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.textPrimary,
                  unselectedLabelColor: AppColors.textSecondary,
                  tabs: [
                    Tab(text: 'Pending'),
                    Tab(text: 'Members'),
                  ],
                )
              else
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('Members', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              Expanded(
                child: isAdmin 
                  ? TabBarView(
                      children: [
                        _MemberList(uids: community.pendingRequests, communityId: communityId, isPending: true),
                        _MemberList(uids: community.members, communityId: communityId, isPending: false),
                      ],
                    )
                  : _MemberList(uids: community.members, communityId: communityId, isPending: false),
              ),
            ],
          ),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }
}

class _MemberList extends ConsumerWidget {
  final List uids;
  final String communityId;
  final bool isPending;

  const _MemberList({required this.uids, required this.communityId, required this.isPending});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (uids.isEmpty) {
      return Center(
        child: Text(
          isPending ? 'No pending requests' : 'No members yet', 
          style: const TextStyle(color: AppColors.textTertiary),
        ),
      );
    }

    final membersAsync = ref.watch(communityMembersProvider(
      communityId: communityId,
      isPending: isPending,
    ));

    return membersAsync.when(
      data: (members) => ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, index) {
          final user = members[index];
          return ListTile(
            leading: UserAvatar(username: user.username, imageUrl: user.profileImage, radius: 20),
            title: Text(user.username, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            trailing: isPending 
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.greenAccent),
                      onPressed: () => ref.read(communityControllerProvider.notifier).approveMember(communityId, user.uid),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.redAccent),
                      onPressed: () => ref.read(communityControllerProvider.notifier).rejectMember(communityId, user.uid),
                    ),
                  ],
                )
              : null, // Kick logic can be added here
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }
}
