import 'dart:typed_data';
import 'package:social_media_app/features/posts/domain/models/post_model.dart';
import 'package:social_media_app/features/posts/domain/models/comment_model.dart';

class PaginatedPostsResponse {
  final List<PostModel> posts;
  final dynamic lastDoc;
  final bool hasMore;

  PaginatedPostsResponse({
    required this.posts,
    this.lastDoc,
    required this.hasMore,
  });
}

abstract class PostRepository {
  Stream<List<PostModel>> getPosts();
  Future<PaginatedPostsResponse> getPaginatedPosts({dynamic lastDoc, int limit = 10});
  Stream<PostModel> getPost(String postId);
  Stream<int> getCommentsCount(String postId);
  Stream<List<CommentModel>> getComments(String postId);
  Stream<bool> isPostSaved(String postId, String uid);
  Stream<bool> isFollowing(String targetUid, String currentUid);
  Stream<int> getUnreadNotificationsCount(String uid);
  Stream<int> getUnreadChatsCount(String uid);
  
  Future<String?> uploadMedia({
    required Uint8List fileBytes,
    required String fileName,
    required bool isVideo,
  });

  Future<String> uploadPost({
    required String uid,
    required String username,
    required String imageUrl,
    required String caption,
    required bool isVideo,
    String? communityId,
    String? codeSnippet,
    String? codeLanguage,
  });

  Future<void> updatePost({
    required String postId,
    required String caption,
    required String codeSnippet,
    required String codeLanguage,
  });
  
  Future<void> likePost(String postId, String uid, List<String> likes);
  Future<void> deletePost(String postId, String? imageUrl);
  Future<void> savePost(String postId, String uid);
  Future<void> followUser(String currentUid, String targetUid);
  
  Future<void> postComment({
    required String postId,
    required String text,
    required String uid,
    required String username,
    required String profileImage,
    String? parentId,
  });

  Future<void> likePostComment(String postId, String commentId, String uid, List<String> likes);
}
