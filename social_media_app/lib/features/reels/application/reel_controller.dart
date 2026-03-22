import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:social_media_app/features/auth/application/auth_controller.dart';
import 'package:social_media_app/features/posts/domain/models/comment_model.dart';
import 'package:social_media_app/features/posts/domain/models/post_model.dart';
import 'package:social_media_app/features/profile/application/profile_controller.dart';
import '../data/repositories/firestore_reel_repository.dart';
import '../domain/repositories/reel_repository.dart';

part 'reel_controller.g.dart';

@riverpod
ReelRepository reelRepository(Ref ref) {
  return FirestoreReelRepository();
}

@riverpod
Stream<List<PostModel>> reelsStream(Ref ref) {
  return ref.watch(reelRepositoryProvider).getReels();
}

@riverpod
Stream<List<CommentModel>> reelComments(Ref ref, String reelId) {
  return ref.watch(reelRepositoryProvider).getReelComments(reelId);
}

@riverpod
class ReelController extends _$ReelController {
  @override
  FutureOr<void> build() {}

  Future<void> likeReel(String reelId, List<String> likes) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;

    await ref.read(reelRepositoryProvider).likeReel(reelId, user.uid, likes);
  }

  Future<void> postComment({
    required String reelId,
    required String text,
    String? parentId,
  }) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;

    final profile = await ref.read(profileProvider(user.uid).future);

    await ref.read(reelRepositoryProvider).postReelComment(
          reelId: reelId,
          text: text,
          uid: user.uid,
          username: profile.username,
          profileImage: profile.profileImage,
          parentId: parentId,
        );
  }

  Future<void> likeComment({
    required String reelId,
    required String commentId,
    required List<String> likes,
  }) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;

    await ref.read(reelRepositoryProvider).likeReelComment(
          reelId,
          commentId,
          user.uid,
          likes,
        );
  }

  Future<String> uploadReel({
    required String caption,
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return 'User not authenticated';

    state = const AsyncLoading();
    try {
      final profile = await ref.read(profileProvider(user.uid).future);
      
      final res = await ref.read(reelRepositoryProvider).uploadReel(
            uid: user.uid,
            username: profile.username,
            caption: caption,
            fileBytes: fileBytes,
            fileName: fileName,
            profileImage: profile.profileImage,
          );
      state = const AsyncData(null);
      return res;
    } catch (e, st) {
      state = AsyncError(e, st);
      return e.toString();
    }
  }
}
