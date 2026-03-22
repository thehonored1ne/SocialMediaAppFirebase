import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:social_media_app/core/constants/app_colors.dart';
import 'package:social_media_app/core/constants/app_constants.dart';
import 'package:social_media_app/core/router/app_routes.dart';
import 'package:social_media_app/features/auth/application/auth_controller.dart';
import 'package:social_media_app/features/posts/application/post_controller.dart';
import 'package:social_media_app/features/posts/domain/models/post_model.dart';
import 'package:social_media_app/core/common/widgets/real_video_player.dart';
import 'package:social_media_app/core/common/widgets/user_avatar.dart';
import 'package:social_media_app/core/common/widgets/dev_features.dart';
import 'package:social_media_app/features/profile/application/profile_controller.dart';
import 'package:social_media_app/features/posts/presentation/widgets/post_comments_sheet.dart';
import 'package:social_media_app/core/utils/snackbar_utils.dart';
import 'package:social_media_app/core/common/widgets/loading_view.dart';
import 'package:social_media_app/features/community/application/community_controller.dart';
import 'package:social_media_app/core/utils/date_utils.dart';

class PostCard extends ConsumerStatefulWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> with TickerProviderStateMixin {
  late AnimationController _likeController;
  late Animation<double> _likeScale;
  bool _showLikeAnimation = false;

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _likeScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _likeController, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _likeController.dispose();
    super.dispose();
  }

  Future<void> _handleDoubleTap(PostModel postData, String uid) async {
    // We allow double tap on text-only posts too
    
    setState(() => _showLikeAnimation = true);
    
    if (!postData.likes.contains(uid)) {
      await ref.read(postControllerProvider.notifier).likePost(
            postData.postId,
            uid,
            postData.likes,
          );
    }
    
    await _likeController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    await _likeController.reverse();
    setState(() => _showLikeAnimation = false);
  }

  @override
  Widget build(BuildContext context) {
    final postAsync = ref.watch(postProvider(widget.post.postId));
    final currentUserId = ref.watch(authStateChangesProvider).value?.uid ?? "";

    return postAsync.when(
      data: (postData) => Container(
        margin: const EdgeInsetsDirectional.symmetric(
          vertical: AppConstants.defaultPadding / 2,
          horizontal: AppConstants.defaultPadding,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius * 2),
          border: Border.all(color: AppColors.textPrimary.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PostHeader(post: postData, currentUserId: currentUserId),
            _PostMedia(
              post: postData,
              likeScale: _likeScale,
              showLikeAnimation: _showLikeAnimation,
              onDoubleTap: () => _handleDoubleTap(postData, currentUserId),
            ),
            _PostActions(post: postData, currentUserId: currentUserId),
            if (postData.imageUrl.isNotEmpty || postData.isVideo || postData.codeSnippet.isNotEmpty)
              _PostCaption(post: postData),
          ],
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}

class _PostHeader extends ConsumerWidget {
  final PostModel post;
  final String currentUserId;

  const _PostHeader({required this.post, required this.currentUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(profileProvider(post.uid));
    final currentUserId = ref.watch(authStateChangesProvider).value?.uid ?? "";
    final isMe = post.uid == currentUserId;
    final textTheme = Theme.of(context).textTheme;

    final communityAsync = post.communityId.isNotEmpty
        ? ref.watch(communityProvider(post.communityId))
        : const AsyncValue.data(null);

    void _showPostMenu() {
      showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isMe) ...[
                ListTile(
                  leading: const Icon(Icons.edit, color: AppColors.textPrimary),
                  title: const Text('Edit Post', style: TextStyle(color: AppColors.textPrimary)),
                  onTap: () {
                    context.pop();
                    context.pushNamed(AppRoutes.editPost, extra: post);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: AppColors.error),
                  title: const Text('Delete Post', style: TextStyle(color: AppColors.error)),
                  onTap: () {
                    context.pop();
                    _confirmDelete(context, ref);
                  },
                ),
              ] else
                ListTile(
                  leading: const Icon(Icons.report, color: AppColors.error),
                  title: const Text('Report', style: TextStyle(color: AppColors.error)),
                  onTap: () {
                    context.pop();
                    SnackBarUtils.showSuccess(context, 'Post reported');
                  },
                ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsetsDirectional.all(AppConstants.defaultPadding),
      child: Row(
        children: [
          userAsync.when(
            data: (user) => GestureDetector(
              onTap: () => context.pushNamed(
                AppRoutes.profile,
                pathParameters: {'uid': post.uid},
              ),
              child: UserAvatar(
                username: post.username,
                imageUrl: user.profileImage,
                radius: 20,
              ),
            ),
            loading: () => const UserAvatar(username: '', imageUrl: '', radius: 20),
            error: (_, __) => UserAvatar(username: post.username, imageUrl: '', radius: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        post.username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (post.communityId.isNotEmpty)
                      communityAsync.when(
                        data: (community) => community != null
                            ? Flexible(
                                child: GestureDetector(
                                  onTap: () => context.pushNamed(
                                    AppRoutes.community,
                                    pathParameters: {'communityId': post.communityId},
                                  ),
                                  child: Text(
                                    ' · ${community.name}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    userAsync.when(
                      data: (user) {
                        final isFollowing = ref.watch(isFollowingUserProvider(post.uid)).valueOrNull ?? false;
                        return !isMe
                            ? Row(
                                children: [
                                  const SizedBox(width: 8),
                                  const Text('•', style: TextStyle(color: AppColors.textTertiary)),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => ref.read(postControllerProvider.notifier).followUser(post.uid),
                                    child: Text(
                                      isFollowing ? 'Unfollow' : 'Follow',
                                      style: TextStyle(
                                        color: isFollowing ? AppColors.textSecondary : AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink();
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
                Text(
                  AppDateUtils.formatTimeAgo(post.timestamp),
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz, color: AppColors.textSecondary),
            onPressed: _showPostMenu,
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Post', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Are you sure you want to delete this post?', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              ref.read(postControllerProvider.notifier).deletePost(post.postId, post.imageUrl);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _PostMedia extends StatelessWidget {
  final PostModel post;
  final Animation<double> likeScale;
  final bool showLikeAnimation;
  final VoidCallback onDoubleTap;

  const _PostMedia({
    required this.post,
    required this.likeScale,
    required this.showLikeAnimation,
    required this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTextOnly = post.imageUrl.isEmpty && !post.isVideo && post.codeSnippet.isEmpty;

    return GestureDetector(
      onTap: () => context.pushNamed(AppRoutes.fullContent, extra: post),
      onDoubleTap: onDoubleTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius * 1.5),
              child: isTextOnly ? _buildTextOnlyContent(context) : _buildMediaContent(),
            ),
          ),
          if (showLikeAnimation)
            ScaleTransition(
              scale: likeScale,
              child: const Icon(Icons.favorite, color: AppColors.textPrimary, size: 100),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaContent() {
    if (post.isVideo) return RealVideoPlayer(videoUrl: post.imageUrl);
    if (post.imageUrl.isNotEmpty) {
      return Image.network(
        post.imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 350,
      );
    }
    return DevCodeSnippet(code: post.codeSnippet, language: post.codeLanguage);
  }

  Widget _buildTextOnlyContent(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 150, maxHeight: 400),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.surface,
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        post.caption,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              height: 1.5,
              letterSpacing: 0.2,
            ),
      ),
    );
  }
}

class _PostActions extends ConsumerWidget {
  final PostModel post;
  final String currentUserId;

  const _PostActions({required this.post, required this.currentUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLiked = post.likes.contains(currentUserId);
    final isSaved = ref.watch(isPostSavedProvider(post.postId)).valueOrNull ?? false;
    final commentCount = ref.watch(postCommentsCountProvider(post.postId)).valueOrNull ?? 0;

    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Row(
        children: [
          _ActionButton(
            icon: isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? AppColors.primary : AppColors.textPrimary,
            label: '${post.likes.length}',
            onTap: () => ref.read(postControllerProvider.notifier).likePost(
                  post.postId,
                  currentUserId,
                  post.likes,
                ),
          ),
          const SizedBox(width: 24),
          _ActionButton(
            icon: Icons.chat_bubble_outline,
            label: '$commentCount',
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => PostCommentsSheet(postId: post.postId),
              );
            },
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: AppColors.textPrimary,
            ),
            onPressed: () => ref.read(postControllerProvider.notifier).savePost(
                  post.postId,
                  currentUserId,
                ),
          ),
        ],
      ),
    );
  }
}

class _PostCaption extends StatelessWidget {
  final PostModel post;

  const _PostCaption({required this.post});

  @override
  Widget build(BuildContext context) {
    if (post.caption.isEmpty) return const SizedBox(height: 12);

    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: AppConstants.defaultPadding,
        end: AppConstants.defaultPadding,
        bottom: AppConstants.defaultPadding,
      ),
      child: Text(
        post.caption,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              height: 1.4,
            ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
