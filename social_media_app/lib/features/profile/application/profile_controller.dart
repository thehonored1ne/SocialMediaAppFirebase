import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:social_media_app/features/auth/domain/models/user_model.dart';
import 'package:social_media_app/features/posts/domain/models/post_model.dart';
import '../data/repositories/github_repository_impl.dart';
import '../domain/repositories/github_repository.dart';
import '../data/repositories/firestore_profile_repository.dart';
import '../domain/repositories/profile_repository.dart';

part 'profile_controller.g.dart';

@riverpod
ProfileRepository profileRepository(Ref ref) {
  return FirestoreProfileRepository();
}

@riverpod
Stream<UserModel> profile(Ref ref, String uid) {
  return ref.watch(profileRepositoryProvider).getUser(uid);
}

@riverpod
Stream<List<UserModel>> suggestedUsers(Ref ref) {
  return ref.watch(profileRepositoryProvider).getSuggestedUsers();
}

@riverpod
Stream<List<PostModel>> userPosts(Ref ref, String uid) {
  return ref.watch(profileRepositoryProvider).getUserPosts(uid);
}

@riverpod
Stream<List<PostModel>> userReels(Ref ref, String uid) {
  return ref.watch(profileRepositoryProvider).getUserReels(uid);
}

@riverpod
Future<List<PostModel>> userBookmarks(Ref ref, List<String> postIds) {
  return ref.watch(profileRepositoryProvider).getBookmarkedPosts(postIds);
}

@riverpod
Future<List<dynamic>> githubTopRepos(Ref ref, String username) {
  return ref.watch(githubRepositoryProvider).fetchTopRepos(username);
}

@riverpod
({int posts, int likes}) profileStats(Ref ref, String uid) {
  final posts = ref.watch(userPostsProvider(uid)).valueOrNull ?? [];
  final reels = ref.watch(userReelsProvider(uid)).valueOrNull ?? [];
  
  final totalPosts = posts.length + reels.length;
  int totalLikes = 0;
  for (final p in posts) {
    totalLikes += p.likes.length;
  }
  for (final r in reels) {
    totalLikes += r.likes.length;
  }
  
  return (posts: totalPosts, likes: totalLikes);
}

@riverpod
class ProfileController extends _$ProfileController {
  @override
  FutureOr<void> build() {}

  Future<String?> uploadImage({
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    state = const AsyncLoading();
    final res = await ref.read(profileRepositoryProvider).uploadProfileImage(
          fileBytes: fileBytes,
          fileName: fileName,
        );
    state = const AsyncData(null);
    return res;
  }

  Future<void> updateProfile({
    required String uid,
    required String username,
    required String bio,
    String? profileImageUrl,
    String? githubUsername,
    String? portfolioUrl,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(profileRepositoryProvider).updateProfile(
            uid: uid,
            username: username,
            bio: bio,
            profileImageUrl: profileImageUrl,
            githubUsername: githubUsername,
            portfolioUrl: portfolioUrl,
          );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
