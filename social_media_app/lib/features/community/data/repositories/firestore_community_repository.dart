import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/core/constants/app_constants.dart';
import 'package:social_media_app/features/community/domain/models/community_model.dart';
import 'package:social_media_app/features/posts/domain/models/post_model.dart';
import '../../domain/repositories/community_repository.dart';

class FirestoreCommunityRepository implements CommunityRepository {
  final FirebaseFirestore _db;

  FirestoreCommunityRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

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

  PostModel _mapToPostModel(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      uid: data['uid'] ?? '',
      username: data['username'] ?? '',
      postId: doc.id,
      imageUrl: data['imageUrl'] ?? '',
      caption: data['caption'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
      isVideo: data['isVideo'] ?? false,
      likes: List<String>.from(data['likes'] ?? []),
      communityId: data['communityId'] ?? '',
      codeSnippet: data['codeSnippet'] ?? '',
      codeLanguage: data['codeLanguage'] ?? 'dart',
    );
  }

  @override
  Stream<List<CommunityModel>> getCommunities() {
    return _db
        .collection(AppConstants.communitiesCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_mapToCommunityModel).toList());
  }

  @override
  Stream<CommunityModel> getCommunity(String id) {
    return _db
        .collection(AppConstants.communitiesCollection)
        .doc(id)
        .snapshots()
        .map(_mapToCommunityModel);
  }

  @override
  Stream<List<PostModel>> getCommunityPosts(String communityId) {
    return _db
        .collection(AppConstants.postsCollection)
        .where('communityId', isEqualTo: communityId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map(_mapToPostModel).toList();
    });
  }

  @override
  Future<String> createCommunity({
    required String name,
    required String description,
    required String adminId,
    String? communityImage,
  }) async {
    try {
      final docRef = await _db.collection(AppConstants.communitiesCollection).add({
        'name': name,
        'name_lowercase': name.toLowerCase().trim(),
        'description': description,
        'adminId': adminId,
        'communityImage': communityImage ?? '',
        'members': [adminId],
        'pendingRequests': [],
        'timestamp': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      return '';
    }
  }

  @override
  Future<void> updateCommunityInfo({
    required String communityId,
    required String name,
    required String description,
    required String imageUrl,
  }) async {
    await _db.collection(AppConstants.communitiesCollection).doc(communityId).update({
      'name': name,
      'name_lowercase': name.toLowerCase().trim(),
      'description': description,
      'communityImage': imageUrl,
    });
  }

  @override
  Future<void> joinCommunity(String communityId, String uid) async {
    await _db.collection(AppConstants.communitiesCollection).doc(communityId).update({
      'members': FieldValue.arrayUnion([uid]),
    });
  }

  @override
  Future<void> requestToJoin(String communityId, String uid) async {
    await _db.collection(AppConstants.communitiesCollection).doc(communityId).update({
      'pendingRequests': FieldValue.arrayUnion([uid]),
    });
  }

  @override
  Future<void> approveMember(String communityId, String uid) async {
    final communityRef = _db.collection(AppConstants.communitiesCollection).doc(communityId);
    await _db.runTransaction((transaction) async {
      transaction.update(communityRef, {
        'pendingRequests': FieldValue.arrayRemove([uid]),
        'members': FieldValue.arrayUnion([uid]),
      });
    });
  }

  @override
  Future<void> rejectMember(String communityId, String uid) async {
    await _db.collection(AppConstants.communitiesCollection).doc(communityId).update({
      'pendingRequests': FieldValue.arrayRemove([uid]),
    });
  }

  @override
  Future<void> kickMember(String communityId, String uid) async {
    await _db.collection(AppConstants.communitiesCollection).doc(communityId).update({
      'members': FieldValue.arrayRemove([uid]),
    });
  }

  @override
  Future<void> leaveCommunity(String communityId, String uid) async {
    await _db.collection(AppConstants.communitiesCollection).doc(communityId).update({
      'members': FieldValue.arrayRemove([uid]),
    });
  }

  @override
  Future<void> updateCommunityImage(String communityId, String imageUrl) async {
    await _db.collection(AppConstants.communitiesCollection).doc(communityId).update({
      'communityImage': imageUrl,
    });
  }
}
