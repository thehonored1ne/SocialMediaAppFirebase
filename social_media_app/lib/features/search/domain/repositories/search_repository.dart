import 'package:social_media_app/features/auth/domain/models/user_model.dart';
import 'package:social_media_app/features/community/domain/models/community_model.dart';

abstract class SearchRepository {
  Stream<List<UserModel>> getSuggestedUsers();
  Stream<List<CommunityModel>> getCommunities();
  Stream<List<UserModel>> searchUsers(String query);
  Stream<List<CommunityModel>> searchCommunities(String query);
}
