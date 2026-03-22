import 'dart:typed_data';
import 'package:social_media_app/features/posts/domain/models/comment_model.dart';
import 'package:social_media_app/features/posts/domain/models/post_model.dart';

abstract class ReelRepository {
  Stream<List<PostModel>> getReels();
  Future<void> likeReel(String reelId, String uid, List<String> likes);
  Stream<List<CommentModel>> getReelComments(String reelId);
  Future<void> postReelComment({
    required String reelId,
    required String text,
    required String uid,
    required String username,
    required String profileImage,
    String? parentId,
  });

  Future<String> uploadReel({
    required String uid,
    required String username,
    required String caption,
    required Uint8List fileBytes,
    required String fileName,
    String? profileImage,
  });
  Future<void> likeReelComment(String reelId, String commentId, String uid, List<String> likes);
}
