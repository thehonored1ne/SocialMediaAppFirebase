import 'dart:typed_data';
import 'package:social_media_app/features/auth/domain/models/user_model.dart';
import 'package:social_media_app/features/posts/domain/models/post_model.dart';

abstract class ProfileRepository {
  Stream<UserModel> getUser(String uid);
  
  Stream<List<PostModel>> getUserPosts(String uid);
  
  Stream<List<PostModel>> getUserReels(String uid);
  
  Future<List<PostModel>> getBookmarkedPosts(List<String> postIds);

  Future<void> updateProfile({
    required String uid,
    required String username,
    required String bio,
    String? profileImageUrl,
    String? githubUsername,
    String? portfolioUrl,
  });

  Future<String?> uploadProfileImage({
    required Uint8List fileBytes,
    required String fileName,
  });

  Stream<List<UserModel>> getSuggestedUsers();
}
