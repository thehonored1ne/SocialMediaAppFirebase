import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:social_media_app/features/auth/application/auth_controller.dart';
import 'package:social_media_app/features/notification/data/repositories/firestore_notification_repository.dart';
import 'package:social_media_app/features/notification/domain/models/notification_model.dart';
import 'package:social_media_app/features/posts/domain/models/comment_model.dart';
import 'package:social_media_app/features/posts/domain/models/post_model.dart';
import 'package:social_media_app/features/profile/application/profile_controller.dart';
import '../data/repositories/firestore_post_repository.dart';
import '../domain/repositories/post_repository.dart';

part 'post_controller.g.dart';

@riverpod
Stream<List<PostModel>> postsStream(Ref ref) {
  return ref.watch(postRepositoryProvider).getPosts();
}

@riverpod
Stream<PostModel> post(Ref ref, String postId) {
  return ref.watch(postRepositoryProvider).getPost(postId);
}

@riverpod
Stream<int> postCommentsCount(Ref ref, String postId) {
  return ref.watch(postRepositoryProvider).getCommentsCount(postId);
}

@riverpod
Stream<List<CommentModel>> postComments(Ref ref, String postId) {
  return ref.watch(postRepositoryProvider).getComments(postId);
}

@riverpod
Stream<bool> isPostSaved(Ref ref, String postId) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value(false);
  return ref.watch(postRepositoryProvider).isPostSaved(postId, user.uid);
}

@riverpod
Stream<bool> isFollowingUser(Ref ref, String targetUid) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value(false);
  return ref.watch(postRepositoryProvider).isFollowing(targetUid, user.uid);
}

@riverpod
Stream<int> unreadNotificationsCount(Ref ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value(0);
  return ref.watch(postRepositoryProvider).getUnreadNotificationsCount(user.uid);
}

@riverpod
Stream<int> unreadChatsCount(Ref ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value(0);
  return ref.watch(postRepositoryProvider).getUnreadChatsCount(user.uid);
}

@riverpod
class PostController extends _$PostController {
  @override
  FutureOr<void> build() {}

  Future<void> likePost(String postId, String uid, List<String> likes) async {
    try {
      final isLiking = !likes.contains(uid);
      await ref.read(postRepositoryProvider).likePost(postId, uid, likes);

      if (isLiking) {
        final postData = await ref.read(postProvider(postId).future);
        final senderProfile = await ref.read(profileProvider(uid).future);

        if (postData.uid != uid) {
          await ref.read(notificationRepositoryProvider).sendNotification(
                NotificationModel(
                  id: '',
                  senderId: uid,
                  senderName: senderProfile.username,
                  senderImage: senderProfile.profileImage,
                  receiverId: postData.uid,
                  type: NotificationType.like,
                  postId: postId,
                  text: 'liked your post.',
                  timestamp: DateTime.now(),
                ),
              );
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> deletePost(String postId, String? imageUrl) async {
    await ref.read(postRepositoryProvider).deletePost(postId, imageUrl);
  }

  Future<void> savePost(String postId, String uid) async {
    await ref.read(postRepositoryProvider).savePost(postId, uid);
  }

  Future<void> followUser(String targetUid) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user != null) {
      await ref.read(postRepositoryProvider).followUser(user.uid, targetUid);
    }
  }

  Future<void> postComment({
    required String postId,
    required String text,
    String? parentId,
  }) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;

    final profile = await ref.read(profileProvider(user.uid).future);

    await ref.read(postRepositoryProvider).postComment(
          postId: postId,
          text: text,
          uid: user.uid,
          username: profile.username,
          profileImage: profile.profileImage,
          parentId: parentId,
        );
  }

  Future<void> likeComment({
    required String postId,
    required String commentId,
    required List<String> likes,
  }) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;

    await ref.read(postRepositoryProvider).likePostComment(
          postId,
          commentId,
          user.uid,
          likes,
        );
  }

  Future<void> updatePost({
    required String postId,
    required String caption,
    required String codeSnippet,
    required String codeLanguage,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(postRepositoryProvider).updatePost(
            postId: postId,
            caption: caption,
            codeSnippet: codeSnippet,
            codeLanguage: codeLanguage,
          );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<String> uploadPost({
    required Uint8List? fileBytes,
    required String? fileName,
    required bool isVideo,
    required String caption,
    required String username,
    String? communityId,
    String? codeSnippet,
    String? codeLanguage,
  }) async {
    state = const AsyncLoading();
    try {
      final user = ref.read(authStateChangesProvider).value;
      if (user == null) return "User not authenticated";

      String imageUrl = "";
      if (fileBytes != null && fileName != null) {
        final uploadRes = await ref.read(postRepositoryProvider).uploadMedia(
              fileBytes: fileBytes,
              fileName: fileName,
              isVideo: isVideo,
            );
        if (uploadRes == null) return "Media upload failed";
        imageUrl = uploadRes;
      }

      final res = await ref.read(postRepositoryProvider).uploadPost(
            uid: user.uid,
            username: username,
            imageUrl: imageUrl,
            caption: caption,
            isVideo: isVideo,
            communityId: communityId,
            codeSnippet: codeSnippet,
            codeLanguage: codeLanguage,
          );
      state = const AsyncData(null);
      return res;
    } catch (e, st) {
      state = AsyncError(e, st);
      return e.toString();
    }
  }
}
