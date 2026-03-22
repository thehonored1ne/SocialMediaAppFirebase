import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:social_media_app/core/constants/app_constants.dart';
import 'package:social_media_app/features/auth/domain/models/user_model.dart';
import 'package:social_media_app/features/posts/domain/models/post_model.dart';
import '../../domain/repositories/profile_repository.dart';

class FirestoreProfileRepository implements ProfileRepository {
  final FirebaseFirestore _db;

  FirestoreProfileRepository({FirebaseFirestore? db})
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
      username: data?['username'] ?? 'Unknown',
      email: data?['email'] ?? '',
      profileImage: imageUrl,
      bio: data?['bio'] ?? '',
      followers: data?['followers'] ?? 0,
      following: data?['following'] ?? 0,
      savedPosts: List<String>.from(data?['saved_posts'] ?? []),
      githubUsername: data?['github_username'],
      portfolioUrl: data?['portfolio_url'],
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
  Stream<UserModel> getUser(String uid) {
    return _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map(_mapToUserModel);
  }

  @override
  Stream<List<UserModel>> getSuggestedUsers() {
    return _db
        .collection(AppConstants.usersCollection)
        .limit(15)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_mapToUserModel).toList());
  }

  @override
  Stream<List<PostModel>> getUserPosts(String uid) {
    return _db
        .collection(AppConstants.postsCollection)
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_mapToPostModel).toList());
  }

  @override
  Stream<List<PostModel>> getUserReels(String uid) {
    return _db
        .collection(AppConstants.reelsCollection)
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_mapToPostModel).toList());
  }

  @override
  Future<List<PostModel>> getBookmarkedPosts(List<String> postIds) async {
    if (postIds.isEmpty) return [];
    
    final List<PostModel> items = [];
    final chunks = <List<String>>[];
    for (var i = 0; i < postIds.length; i += 10) {
      chunks.add(postIds.sublist(i, i + 10 > postIds.length ? postIds.length : i + 10));
    }

    for (final chunk in chunks) {
      final postsQuery = await _db
          .collection(AppConstants.postsCollection)
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      
      final reelsQuery = await _db
          .collection(AppConstants.reelsCollection)
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      items.addAll(postsQuery.docs.map(_mapToPostModel));
      items.addAll(reelsQuery.docs.map(_mapToPostModel));
    }

    items.sort((a, b) {
      final aTime = a.timestamp;
      final bTime = b.timestamp;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });

    return items;
  }

  @override
  Future<void> updateProfile({
    required String uid,
    required String username,
    required String bio,
    String? profileImageUrl,
    String? githubUsername,
    String? portfolioUrl,
  }) async {
    final Map<String, dynamic> data = {
      'username': username,
      'username_lowercase': username.toLowerCase().trim(),
      'bio': bio,
      'github_username': githubUsername,
      'portfolio_url': portfolioUrl,
    };

    if (profileImageUrl != null) {
      data['profileImage'] = profileImageUrl;
    }

    await _db.collection(AppConstants.usersCollection).doc(uid).update(data);
  }

  @override
  Future<String?> uploadProfileImage({
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    try {
      final url = Uri.parse(
        "https://api.cloudinary.com/v1_1/${AppConstants.cloudinaryCloudName}/image/upload",
      );

      var request = http.MultipartRequest("POST", url);
      request.fields['upload_preset'] = AppConstants.cloudinaryUploadPreset;
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
      ));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(responseData);
        return jsonResponse['secure_url'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
