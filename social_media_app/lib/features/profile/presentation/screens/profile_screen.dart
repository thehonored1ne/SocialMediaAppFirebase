import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:social_media_app/core/constants/app_colors.dart';
import 'package:social_media_app/core/constants/app_constants.dart';
import 'package:social_media_app/core/router/app_routes.dart';
import 'package:social_media_app/features/auth/application/auth_controller.dart';
import 'package:social_media_app/features/posts/domain/models/post_model.dart';
import 'package:social_media_app/features/posts/presentation/widgets/post_card.dart';
import 'package:social_media_app/features/profile/application/profile_controller.dart';
import 'package:social_media_app/core/common/widgets/sticky_tab_delegate.dart';
import '../widgets/profile_header.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String? uid;
  const ProfileScreen({super.key, this.uid});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(authStateChangesProvider).value?.uid;
    final targetUid = widget.uid ?? currentUserId ?? "";
    final isMe = targetUid == currentUserId;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          physics: const BouncingScrollPhysics(),
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              pinned: false,
              leading: !isMe
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textPrimary),
                      onPressed: () => context.pop(),
                    )
                  : null,
              title: Text(
                'DevNotes',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              actions: [
                if (isMe)
                  IconButton(
                    icon: const Icon(Icons.menu_rounded,
                        color: AppColors.textPrimary, size: 30),
                    onPressed: () => context.pushNamed(AppRoutes.settings),
                  ),
              ],
            ),
            SliverToBoxAdapter(
              child: ProfileHeader(uid: targetUid),
            ),
            SliverToBoxAdapter(
              child: _RepoList(uid: targetUid),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: StickyTabDelegate(
                TabBar(
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 2,
                  dividerColor: AppColors.textPrimary.withValues(alpha: 0.1),
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  tabs: const [
                    Tab(icon: Icon(Icons.grid_on_rounded)),
                    Tab(icon: Icon(Icons.video_library_outlined)),
                    Tab(icon: Icon(Icons.bookmark_outline)),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _ProfileGrid(uid: targetUid, type: _GridType.posts),
              _ProfileGrid(uid: targetUid, type: _GridType.reels),
              _ProfileGrid(uid: targetUid, type: _GridType.bookmarks),
            ],
          ),
        ),
      ),
    );
  }
}

enum _GridType { posts, reels, bookmarks }

class _ProfileGrid extends ConsumerWidget {
  final String uid;
  final _GridType type;

  const _ProfileGrid({required this.uid, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = _getProvider(ref);

    return provider.when(
      data: (items) {
        if (items.isEmpty) {
          return _EmptyState(
            icon: _getIcon(),
            message: _getMessage(),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(2),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            childAspectRatio: type == _GridType.reels ? 0.6 : 1.0,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return GestureDetector(
              onTap: () => _navigateToDetail(context, item),
              child: _GridThumbnail(post: item),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
    );
  }

  AsyncValue<List<PostModel>> _getProvider(WidgetRef ref) {
    switch (type) {
      case _GridType.posts:
        return ref.watch(userPostsProvider(uid));
      case _GridType.reels:
        return ref.watch(userReelsProvider(uid));
      case _GridType.bookmarks:
        final user = ref.watch(profileProvider(uid)).valueOrNull;
        final savedPosts = user?.savedPosts ?? [];
        return ref.watch(userBookmarksProvider(savedPosts));
    }
  }

  IconData _getIcon() {
    switch (type) {
      case _GridType.posts: return Icons.grid_on_rounded;
      case _GridType.reels: return Icons.video_library_outlined;
      case _GridType.bookmarks: return Icons.bookmark_outline;
    }
  }

  String _getMessage() {
    switch (type) {
      case _GridType.posts: return "No posts yet";
      case _GridType.reels: return "No reels yet";
      case _GridType.bookmarks: return "No bookmarks yet";
    }
  }

  void _navigateToDetail(BuildContext context, PostModel post) {
    context.pushNamed(AppRoutes.postDetail, extra: post);
  }
}

class _RepoList extends ConsumerWidget {
  final String uid;
  const _RepoList({required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(profileProvider(uid));
    
    return userAsync.when(
      data: (user) {
        if (user.githubUsername == null || user.githubUsername!.isEmpty) {
          return const SizedBox.shrink();
        }

        final reposAsync = ref.watch(githubTopReposProvider(user.githubUsername!));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.star_outline_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Top Repositories',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 140,
              child: reposAsync.when(
                data: (repos) => ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      ...ScrollConfiguration.of(context).dragDevices,
                      PointerDeviceKind.mouse,
                    },
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding - 8),
                    itemCount: repos.length,
                    itemBuilder: (context, index) => _RepoCard(repo: repos[index]),
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Text('Could not load repos', style: TextStyle(color: AppColors.error, fontSize: 12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _RepoCard extends StatelessWidget {
  final dynamic repo;
  const _RepoCard({required this.repo});

  Future<void> _launchRepo() async {
    final url = Uri.parse(repo['html_url']);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launchRepo,
      child: Container(
        width: 160,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(color: AppColors.textPrimary.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              repo['name'] ?? 'Repository',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                repo['description'] ?? 'No description provided',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star_rounded, size: 12, color: AppColors.accent),
                const SizedBox(width: 4),
                Text(
                  '${repo['stargazers_count'] ?? 0}',
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
                const Spacer(),
                if (repo['language'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      repo['language'],
                      style: const TextStyle(fontSize: 8, color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GridThumbnail extends StatelessWidget {
  final PostModel post;
  const _GridThumbnail({required this.post});

  String _getThumbnailUrl(String url) {
    if (url.contains('cloudinary.com') && (url.endsWith('.mp4') || url.contains('/video/upload/'))) {
      // Cloudinary trick: Change extension to .jpg for auto-generated thumbnail
      return url.replaceAll(RegExp(r'\.mp4($|\?)'), '.jpg').replaceAll('/video/upload/', '/video/upload/so_0/');
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    if (post.imageUrl.isEmpty) {
      return Container(
        color: AppColors.surface,
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Text(
            post.codeSnippet.isNotEmpty ? post.codeSnippet : post.caption,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 8, color: AppColors.textSecondary, fontFamily: 'monospace'),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final isActuallyVideo = post.isVideo || post.imageUrl.toLowerCase().endsWith('.mp4');
    final displayUrl = _getThumbnailUrl(post.imageUrl);

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          displayUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.surface,
              child: const Icon(Icons.videocam_off_outlined, color: AppColors.textTertiary),
            );
          },
        ),
        if (isActuallyVideo)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
            ),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: AppColors.textPrimary.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
