import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:social_media_app/core/constants/app_colors.dart';
import 'package:social_media_app/core/constants/app_constants.dart';
import 'package:social_media_app/core/router/app_routes.dart';
import 'package:social_media_app/features/auth/domain/models/user_model.dart';
import 'package:social_media_app/features/posts/application/post_controller.dart';
import 'package:social_media_app/features/search/application/search_controller.dart';
import 'package:social_media_app/core/common/widgets/user_avatar.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchControllerProvider);
    final isSearching = query.isNotEmpty;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _SearchAppBar(
            controller: _searchController,
            onChanged: (val) => ref.read(searchControllerProvider.notifier).updateQuery(val),
          ),
          if (!isSearching) ...[
            _SectionHeader(title: 'Suggested for you', textTheme: textTheme),
            const _SuggestedUsersList(),
            _SectionHeader(title: 'Browse Communities', textTheme: textTheme),
            const _CommunityList(),
          ] else ...[
            const _SearchResultsSection(),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _SearchAppBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchAppBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.background.withValues(alpha: 0.95),
      elevation: 0,
      title: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.textPrimary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.textPrimary.withValues(alpha: 0.05)),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: const InputDecoration(
            hintText: 'Search creators or communities...',
            hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            prefixIcon: Icon(Icons.search, color: AppColors.textSecondary, size: 20),
            border: InputBorder.none,
            contentPadding: EdgeInsetsDirectional.symmetric(vertical: 12),
          ),
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final TextTheme textTheme;

  const _SectionHeader({required this.title, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppConstants.defaultPadding,
          20,
          AppConstants.defaultPadding,
          12,
        ),
        child: Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _SuggestedUsersList extends ConsumerWidget {
  const _SuggestedUsersList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestedAsync = ref.watch(suggestedUsersProvider);

    return suggestedAsync.when(
      data: (users) => SliverToBoxAdapter(
        child: SizedBox(
          height: 190,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                ...ScrollConfiguration.of(context).dragDevices,
                PointerDeviceKind.mouse,
              },
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
              physics: const BouncingScrollPhysics(),
              itemCount: users.length,
              itemBuilder: (context, index) => _UserSuggestionCard(user: users[index]),
            ),
          ),
        ),
      ),
      loading: () => const SliverToBoxAdapter(child: SizedBox(height: 190)),
      error: (_, _) => const SliverToBoxAdapter(child: SizedBox()),
    );
  }
}

class _UserSuggestionCard extends ConsumerWidget {
  final UserModel user;

  const _UserSuggestionCard({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFollowing = ref.watch(isFollowingUserProvider(user.uid)).valueOrNull ?? false;

    return Container(
      width: 140,
      margin: const EdgeInsetsDirectional.symmetric(horizontal: 6, vertical: 4),
      padding: const EdgeInsetsDirectional.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.textPrimary.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => context.pushNamed(AppRoutes.profile, pathParameters: {'uid': user.uid}),
            child: UserAvatar(username: user.username, imageUrl: user.profileImage, radius: 35),
          ),
          const SizedBox(height: 10),
          Text(
            user.username,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => ref.read(postControllerProvider.notifier).followUser(user.uid),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsetsDirectional.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isFollowing ? AppColors.textPrimary.withValues(alpha: 0.1) : AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  isFollowing ? 'Following' : 'Follow',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isFollowing ? AppColors.textSecondary : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunityList extends ConsumerWidget {
  const _CommunityList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communitiesAsync = ref.watch(browseCommunitiesProvider);

    return communitiesAsync.when(
      data: (communities) => SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final community = communities[index];
            return ListTile(
              onTap: () => context.pushNamed(AppRoutes.community, pathParameters: {'communityId': community.id}),
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.textPrimary.withValues(alpha: 0.1),
                backgroundImage: community.communityImage.isNotEmpty ? NetworkImage(community.communityImage) : null,
                child: community.communityImage.isEmpty ? const Icon(Icons.groups_outlined, color: AppColors.textSecondary) : null,
              ),
              title: Text(community.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              subtitle: Text('${community.members.length} members', style: const TextStyle(color: AppColors.textSecondary)),
            );
          },
          childCount: communities.length,
        ),
      ),
      loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
      error: (_, _) => const SliverToBoxAdapter(child: SizedBox()),
    );
  }
}

class _SearchResultsSection extends ConsumerWidget {
  const _SearchResultsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userResults = ref.watch(searchUsersResultsProvider);
    final communityResults = ref.watch(searchCommunitiesResultsProvider);

    return SliverMainAxisGroup(
      slivers: [
        communityResults.when(
          data: (communities) => SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == 0) return const _ResultHeader(title: 'Communities');
                final community = communities[index - 1];
                return ListTile(
                  onTap: () => context.pushNamed(AppRoutes.community, pathParameters: {'communityId': community.id}),
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.textPrimary.withValues(alpha: 0.1),
                    backgroundImage: community.communityImage.isNotEmpty ? NetworkImage(community.communityImage) : null,
                    child: community.communityImage.isEmpty ? const Icon(Icons.groups_outlined, color: AppColors.textSecondary) : null,
                  ),
                  title: Text(community.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                  subtitle: Text('${community.members.length} members', style: const TextStyle(color: AppColors.textSecondary)),
                );
              },
              childCount: communities.isEmpty ? 0 : communities.length + 1,
            ),
          ),
          loading: () => const SliverToBoxAdapter(child: SizedBox()),
          error: (_, _) => const SliverToBoxAdapter(child: SizedBox()),
        ),
        userResults.when(
          data: (users) => SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == 0) return const _ResultHeader(title: 'Creators');
                final user = users[index - 1];
                return ListTile(
                  onTap: () => context.pushNamed(AppRoutes.profile, pathParameters: {'uid': user.uid}),
                  leading: UserAvatar(username: user.username, imageUrl: user.profileImage, radius: 20),
                  title: Text(user.username, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                  subtitle: Text(user.bio, style: const TextStyle(color: AppColors.textSecondary), maxLines: 1),
                );
              },
              childCount: users.isEmpty ? 0 : users.length + 1,
            ),
          ),
          loading: () => const SliverToBoxAdapter(child: SizedBox()),
          error: (_, _) => const SliverToBoxAdapter(child: SizedBox()),
        ),
      ],
    );
  }
}

class _ResultHeader extends StatelessWidget {
  final String title;

  const _ResultHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
      child: Text(title, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
