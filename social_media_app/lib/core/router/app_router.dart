import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:social_media_app/core/router/app_routes.dart';
import 'package:social_media_app/features/auth/application/auth_controller.dart';
import 'package:social_media_app/features/auth/presentation/screens/login_screen.dart';
import 'package:social_media_app/features/auth/presentation/screens/register_screen.dart';
import 'package:social_media_app/features/community/domain/models/community_model.dart';
import 'package:social_media_app/features/community/presentation/screens/edit_community_screen.dart';
import 'package:social_media_app/features/chat/presentation/screens/chat_detail_screen.dart';
import 'package:social_media_app/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:social_media_app/features/notification/presentation/screens/notification_screen.dart';
import 'package:social_media_app/features/home/presentation/screens/root_screen.dart';
import 'package:social_media_app/features/posts/domain/models/post_model.dart';
import 'package:social_media_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:social_media_app/features/auth/domain/models/user_model.dart';
import 'package:social_media_app/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:social_media_app/features/profile/presentation/screens/settings_screen.dart';
import 'package:social_media_app/features/community/presentation/screens/community_detail_screen.dart';
import 'package:social_media_app/features/posts/presentation/screens/edit_post_screen.dart';
import 'package:social_media_app/features/posts/presentation/widgets/post_card.dart';
import 'package:social_media_app/features/reels/presentation/screens/reels_screen.dart';
import 'package:social_media_app/features/search/presentation/screens/search_screen.dart';
import 'package:social_media_app/features/reels/presentation/screens/add_reel_screen.dart';
import 'package:social_media_app/features/story/presentation/screens/add_story_screen.dart';
import 'package:social_media_app/features/story/presentation/screens/story_view_screen.dart';
import 'package:social_media_app/features/story/domain/models/story_model.dart';
import 'package:social_media_app/features/posts/presentation/screens/post_screen.dart';
import 'package:social_media_app/features/community/presentation/screens/create_community_screen.dart';
import 'package:social_media_app/features/posts/presentation/screens/feed_screen.dart';
import 'package:social_media_app/features/posts/presentation/screens/full_content_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: authState.when(
      data: (user) => _RouterRefreshNotifier(user),
      error: (_, _) => _RouterRefreshNotifier(null),
      loading: () => _RouterRefreshNotifier(null),
    ),
    redirect: (context, state) {
      final user = authState.valueOrNull;
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (user == null) {
        return isAuthRoute ? null : '/login';
      }

      if (isAuthRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return RootScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: AppRoutes.feed,
                builder: (context, state) => const FeedScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                name: AppRoutes.search,
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reels',
                name: AppRoutes.reels,
                builder: (context, state) => const ReelsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: ':uid',
                    name: AppRoutes.profile,
                    builder: (context, state) {
                      final uid = state.pathParameters['uid']!;
                      return ProfileScreen(uid: uid);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        name: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/community/:communityId',
        name: AppRoutes.community,
        builder: (context, state) {
          final communityId = state.pathParameters['communityId']!;
          return CommunityDetailScreen(communityId: communityId);
        },
      ),
      GoRoute(
        path: '/notifications',
        name: AppRoutes.notifications,
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        path: '/messages',
        name: AppRoutes.messages,
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: '/chat',
        name: AppRoutes.chat,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return ChatDetailScreen(
            otherUserId: data['otherUserId'] as String,
            otherUserName: data['otherUserName'] as String,
            otherUserImage: data['otherUserImage'] as String,
          );
        },
      ),
      GoRoute(
        path: '/create-post',
        name: AppRoutes.createPost,
        builder: (context, state) {
          final extra = state.extra;
          String? communityId;
          if (extra is String) {
            communityId = extra;
          } else if (extra is Map<String, dynamic>) {
            communityId = extra['communityId'] as String?;
          }
          return PostScreen(
            onClose: () => context.pop(),
            communityId: communityId,
          );
        },
      ),
      GoRoute(
        path: '/create-story',
        name: AppRoutes.createStory,
        builder: (context, state) => const AddStoryScreen(),
      ),
      GoRoute(
        path: '/create-reel',
        name: AppRoutes.createReel,
        builder: (context, state) => const AddReelScreen(),
      ),
      GoRoute(
        path: '/create-community',
        name: AppRoutes.createCommunity,
        builder: (context, state) => const CreateCommunityScreen(),
      ),
      GoRoute(
        path: '/story-view',
        name: AppRoutes.storyView,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return StoryViewScreen(
            stories: data['stories'] as List<StoryModel>,
            username: data['username'] as String,
            profileImage: data['profileImage'] as String,
          );
        },
      ),
      GoRoute(
        path: '/edit-post',
        name: AppRoutes.editPost,
        builder: (context, state) {
          final post = state.extra as PostModel;
          return EditPostScreen(post: post);
        },
      ),
      GoRoute(
        path: '/edit-community',
        name: AppRoutes.editCommunity,
        builder: (context, state) {
          final community = state.extra as CommunityModel;
          return EditCommunityScreen(community: community);
        },
      ),
      GoRoute(
        path: '/post-detail',
        name: AppRoutes.postDetail,
        builder: (context, state) {
          final post = state.extra as PostModel;
          return Scaffold(
            appBar: AppBar(title: Text(post.isVideo ? 'Reel' : 'Post')),
            body: PostCard(post: post),
          );
        },
      ),
      GoRoute(
        path: '/full-content',
        name: AppRoutes.fullContent,
        builder: (context, state) {
          final post = state.extra as PostModel;
          return FullContentScreen(post: post);
        },
      ),
      GoRoute(
        path: '/edit-profile',
        name: AppRoutes.editProfile,
        builder: (context, state) {
          final user = state.extra as UserModel;
          return EditProfileScreen(user: user);
        },
      ),
      GoRoute(
        path: '/settings',
        name: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}

class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Object? value) {
    notifyListeners();
  }
}
