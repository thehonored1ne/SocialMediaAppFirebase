import 'package:social_media_app/features/community/domain/models/community_model.dart';
import 'package:social_media_app/features/posts/domain/models/post_model.dart';

abstract class CommunityRepository {
  Stream<List<CommunityModel>> getCommunities();
  Stream<CommunityModel> getCommunity(String id);
  Stream<List<PostModel>> getCommunityPosts(String communityId);
  
  Future<String> createCommunity({
    required String name,
    required String description,
    required String adminId,
    String? communityImage,
  });

  Future<void> updateCommunityInfo({
    required String communityId,
    required String name,
    required String description,
    required String imageUrl,
  });

  Future<void> joinCommunity(String communityId, String uid);
  Future<void> requestToJoin(String communityId, String uid);
  Future<void> approveMember(String communityId, String uid);
  Future<void> rejectMember(String communityId, String uid);
  Future<void> kickMember(String communityId, String uid);
  Future<void> leaveCommunity(String communityId, String uid);
  Future<void> updateCommunityImage(String communityId, String imageUrl);
}
