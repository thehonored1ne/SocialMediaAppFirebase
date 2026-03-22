import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:social_media_app/core/constants/app_colors.dart';
import 'package:social_media_app/core/router/app_routes.dart';
import 'package:social_media_app/features/posts/application/post_controller.dart';
import 'package:social_media_app/features/posts/application/paginated_post_controller.dart';
import 'package:social_media_app/core/providers/scroll_notifier.dart';
import '../widgets/post_card.dart';
import 'package:social_media_app/features/story/presentation/widgets/story_bar.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => FeedScreenState();
}

class FeedScreenState extends ConsumerState<FeedScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(paginatedPostControllerProvider.notifier).fetchMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(homeScrollNotifierProvider, (_, __) => scrollToTop());
    final postsAsync = ref.watch(paginatedPostControllerProvider);
    final unreadNotifs = ref.watch(unreadNotificationsCountProvider).valueOrNull ?? 0;
    final unreadChats = ref.watch(unreadChatsCountProvider).valueOrNull ?? 0;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(paginatedPostControllerProvider.future),
        backgroundColor: AppColors.surface,
        color: AppColors.primary,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              snap: true,
              elevation: 0,
              backgroundColor: AppColors.background.withValues(alpha: 0.9),
              title: Text(
                'DevNotes',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.2,
                  color: AppColors.textPrimary,
                ),
              ),
              actions: [
                _buildBadgeIcon(
                  icon: Icons.notifications_none_rounded,
                  count: unreadNotifs,
                  onPressed: () => context.pushNamed(AppRoutes.notifications),
                ),
                _buildBadgeIcon(
                  icon: Icons.send_rounded,
                  count: unreadChats,
                  onPressed: () => context.pushNamed(AppRoutes.messages),
                ),
                const SizedBox(width: 8),
              ],
            ),
            const SliverToBoxAdapter(
              child: StoryBar(),
            ),
            postsAsync.when(
              data: (posts) {
                if (posts.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome_motion_outlined,
                              size: 60, color: AppColors.textTertiary),
                          SizedBox(height: 16),
                          Text('Your feed is empty.',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.bold)),
                          Text('Be the first to post something!',
                              style: TextStyle(color: AppColors.textTertiary)),
                        ],
                      ),
                    ),
                  );
                }
                final hasMore = ref.watch(paginatedPostControllerProvider.notifier).hasMore;
                return SliverMainAxisGroup(
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final post = posts[index];
                          return PostCard(
                            key: ValueKey(post.postId),
                            post: post,
                          );
                        },
                        childCount: posts.length,
                      ),
                    ),
                    if (hasMore)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary)),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.primary))),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeIcon({
    required IconData icon,
    required int count,
    required VoidCallback onPressed,
  }) {
    return Badge(
      label: Text(count.toString()),
      isLabelVisible: count > 0,
      backgroundColor: AppColors.primary,
      offset: const Offset(-4, 4),
      child: IconButton(
        icon: Icon(icon, color: AppColors.textPrimary),
        onPressed: onPressed,
      ),
    );
  }
}
