import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/core/constants/app_constants.dart';
import 'package:social_media_app/features/auth/domain/models/user_model.dart';
import 'package:social_media_app/features/community/domain/models/community_model.dart';
import '../../domain/repositories/search_repository.dart';

class FirestoreSearchRepository implements SearchRepository {
  final FirebaseFirestore _db;

  FirestoreSearchRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  UserModel _mapToUserModel(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    // Check multiple common field names for profile image to be robust
    final String imageUrl = data?['profileImage'] ?? 
                           data?['profileImageUrl'] ?? 
                           data?['photoUrl'] ?? 
                           '';

    return UserModel(
      uid: doc.id,
      username: data?['username'] ?? '',
      email: data?['email'] ?? '',
      profileImage: imageUrl,
      bio: data?['bio'] ?? '',
      followers: data?['followers'] ?? 0,
      following: data?['following'] ?? 0,
      savedPosts: List<String>.from(data?['saved_posts'] ?? []),
    );
  }

  CommunityModel _mapToCommunityModel(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommunityModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      adminId: data['adminId'] ?? '',
      communityImage: data['communityImage'] ?? '',
      members: List<String>.from(data['members'] ?? []),
      pendingRequests: List<String>.from(data['pendingRequests'] ?? []),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
    );
  }

  @override
  Stream<List<UserModel>> getSuggestedUsers() {
    return _db
        .collection(AppConstants.usersCollection)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map(_mapToUserModel).toList();
    });
  }

  @override
  Stream<List<CommunityModel>> getCommunities() {
    return _db
        .collection(AppConstants.communitiesCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map(_mapToCommunityModel).toList();
    });
  }

  @override
  Stream<List<UserModel>> searchUsers(String query) {
    final searchText = query.toLowerCase().trim();
    return _db
        .collection(AppConstants.usersCollection)
        .where('username_lowercase', isGreaterThanOrEqualTo: searchText)
        .where('username_lowercase', isLessThanOrEqualTo: '$searchText\uf8ff')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map(_mapToUserModel).toList();
    });
  }

  @override
  Stream<List<CommunityModel>> searchCommunities(String query) {
    final searchText = query.toLowerCase().trim();
    return _db
        .collection(AppConstants.communitiesCollection)
        .where('name_lowercase', isGreaterThanOrEqualTo: searchText)
        .where('name_lowercase', isLessThanOrEqualTo: '$searchText\uf8ff')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map(_mapToCommunityModel).toList();
    });
  }
}
