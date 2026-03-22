import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_media_app/core/common/widgets/user_avatar.dart';
import 'package:go_router/go_router.dart';
import 'package:social_media_app/core/router/app_routes.dart';
import 'package:social_media_app/core/constants/app_colors.dart';
import 'package:social_media_app/features/auth/application/auth_controller.dart';
import 'package:social_media_app/features/profile/application/profile_controller.dart';
import 'package:social_media_app/features/story/application/story_controller.dart';
import 'package:social_media_app/features/story/domain/models/story_model.dart';

class StoryBar extends ConsumerWidget {
  const StoryBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authStateChangesProvider).value;
    if (currentUser == null) return const SizedBox.shrink();

    final groupedStoriesAsync = ref.watch(groupedStoriesProvider);
    final profileAsync = ref.watch(profileProvider(currentUser.uid));

    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: groupedStoriesAsync.when(
        data: (storyGroups) {
          final List<String> otherUids = storyGroups.keys
              .where((uid) => uid != currentUser.uid)
              .toList();
          
          final bool iHaveStories = storyGroups.containsKey(currentUser.uid);

          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                ...ScrollConfiguration.of(context).dragDevices,
                PointerDeviceKind.mouse,
              },
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                if (iHaveStories)
                  _MyStoryCircle(
                    stories: storyGroups[currentUser.uid]!,
                    profileImage: profileAsync.valueOrNull?.profileImage ?? '',
                  )
                else
                  _AddStoryButton(
                    profileImage: profileAsync.valueOrNull?.profileImage ?? '',
                    username: profileAsync.valueOrNull?.username ?? 'Me',
                  ),

                ...otherUids.map((uid) {
                  final stories = storyGroups[uid]!;
                  return _StoryCircle(
                    stories: stories,
                    username: stories[0].username,
                    profileImage: stories[0].profileImage,
                  );
                }),
              ],
            ),
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const SizedBox.shrink(),
      ),
    );
  }
}

class _AddStoryButton extends StatelessWidget {
  final String profileImage;
  final String username;

  const _AddStoryButton({required this.profileImage, required this.username});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              context.pushNamed(AppRoutes.createStory);
            },
            child: Stack(
              children: [
                UserAvatar(username: username, imageUrl: profileImage, radius: 30),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.add, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text('Add Story', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _MyStoryCircle extends StatelessWidget {
  final List<StoryModel> stories;
  final String profileImage;

  const _MyStoryCircle({required this.stories, required this.profileImage});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  context.pushNamed(
                    AppRoutes.storyView,
                    extra: {
                      'stories': stories,
                      'username': 'Me',
                      'profileImage': profileImage,
                    },
                  );
                },
                child: _StoryBorder(
                  child: UserAvatar(username: 'Me', imageUrl: profileImage, radius: 30),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    context.pushNamed(AppRoutes.createStory);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.add, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text('Your Story', style: TextStyle(fontSize: 11, color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _StoryCircle extends StatelessWidget {
  final List<StoryModel> stories;
  final String username;
  final String profileImage;

  const _StoryCircle({required this.stories, required this.username, required this.profileImage});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              context.pushNamed(
                AppRoutes.storyView,
                extra: {
                  'stories': stories,
                  'username': username,
                  'profileImage': profileImage,
                },
              );
            },
            child: _StoryBorder(
              child: UserAvatar(username: username, imageUrl: profileImage, radius: 30),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 64,
            child: Text(
              username,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryBorder extends StatelessWidget {
  final Widget child;
  const _StoryBorder({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
        child: child,
      ),
    );
  }
}
