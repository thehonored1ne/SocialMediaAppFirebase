import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:social_media_app/core/constants/app_constants.dart';
import 'package:social_media_app/features/posts/domain/models/post_model.dart';
import 'package:social_media_app/features/posts/domain/models/comment_model.dart';
import '../../domain/repositories/post_repository.dart';

part 'firestore_post_repository.g.dart';

@riverpod
PostRepository postRepository(Ref ref) {
  return FirestorePostRepository();
}

class FirestorePostRepository implements PostRepository {
  final FirebaseFirestore _db;

  FirestorePostRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

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
  Stream<List<PostModel>> getPosts() {
    return _db
        .collection(AppConstants.postsCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map(_mapToPostModel).toList();
    });
  }

  @override
  Future<PaginatedPostsResponse> getPaginatedPosts({dynamic lastDoc, int limit = 10}) async {
    Query query = _db
        .collection(AppConstants.postsCollection)
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (lastDoc != null && lastDoc is QueryDocumentSnapshot) {
      query = query.startAfterDocument(lastDoc);
    }

    final snapshot = await query.get();
    final posts = snapshot.docs.map(_mapToPostModel).toList();
    
    return PaginatedPostsResponse(
      posts: posts,
      lastDoc: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: snapshot.docs.length == limit,
    );
  }

  @override
  Stream<PostModel> getPost(String postId) {
    return _db
        .collection(AppConstants.postsCollection)
        .doc(postId)
        .snapshots()
        .map(_mapToPostModel);
  }

  @override
  Stream<int> getCommentsCount(String postId) {
    return _db
        .collection(AppConstants.postsCollection)
        .doc(postId)
        .collection('comments')
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  @override
  Stream<List<CommentModel>> getComments(String postId) {
    return _db
        .collection(AppConstants.postsCollection)
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map<CommentModel>((doc) {
        final data = doc.data();
        return CommentModel(
          commentId: doc.id,
          uid: data['uid'] ?? '',
          username: data['username'] ?? '',
          profileImage: data['profileImage'] ?? '',
          text: data['text'] ?? '',
          timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
          likes: List<String>.from(data['likes'] ?? []),
          parentId: data['parentId'] ?? '',
        );
      }).toList();
    });
  }

  @override
  Stream<bool> isPostSaved(String postId, String uid) {
    return _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      final List savedPosts = data?['saved_posts'] ?? [];
      return savedPosts.contains(postId);
    });
  }

  @override
  Stream<bool> isFollowing(String targetUid, String currentUid) {
    return _db
        .collection(AppConstants.usersCollection)
        .doc(currentUid)
        .snapshots()
        .map((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      final List following = data?['following_list'] ?? [];
      return following.contains(targetUid);
    });
  }

  @override
  Stream<int> getUnreadNotificationsCount(String uid) {
    return _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .collection(AppConstants.notificationsCollection)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  @override
  Stream<int> getUnreadChatsCount(String uid) {
    return _db
        .collection(AppConstants.chatsCollection)
        .where('users', arrayContains: uid)
        .snapshots()
        .map((snap) {
      return snap.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final List seenBy = data['seenBy'] ?? [];
        return !seenBy.contains(uid);
      }).length;
    });
  }

  @override
  Future<String?> uploadMedia({
    required Uint8List fileBytes,
    required String fileName,
    required bool isVideo,
  }) async {
    try {
      final resourceType = isVideo ? "video" : "image";
      final url = Uri.parse(
        "https://api.cloudinary.com/v1_1/${AppConstants.cloudinaryCloudName}/$resourceType/upload",
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

  @override
  Future<String> uploadPost({
    required String uid,
    required String username,
    required String imageUrl,
    required String caption,
    required bool isVideo,
    String? communityId,
    String? codeSnippet,
    String? codeLanguage,
  }) async {
    try {
      await _db.collection(AppConstants.postsCollection).add({
        'uid': uid,
        'username': username,
        'imageUrl': imageUrl,
        'caption': caption,
        'timestamp': FieldValue.serverTimestamp(),
        'isVideo': isVideo,
        'likes': [],
        'communityId': communityId ?? '',
        'codeSnippet': codeSnippet ?? '',
        'codeLanguage': codeLanguage ?? 'dart',
      });
      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Future<void> updatePost({
    required String postId,
    required String caption,
    required String codeSnippet,
    required String codeLanguage,
  }) async {
    await _db.collection(AppConstants.postsCollection).doc(postId).update({
      'caption': caption,
      'codeSnippet': codeSnippet,
      'codeLanguage': codeLanguage,
    });
  }

  @override
  Future<void> likePost(String postId, String uid, List<String> likes) async {
    try {
      final postRef = _db.collection(AppConstants.postsCollection).doc(postId);
      if (likes.contains(uid)) {
        await postRef.update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        await postRef.update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
    } catch (e) {
      // Error handling
    }
  }

  @override
  Future<void> deletePost(String postId, String? imageUrl) async {
    try {
      await _db.collection(AppConstants.postsCollection).doc(postId).delete();
    } catch (e) {
      // Error handling
    }
  }

  @override
  Future<void> savePost(String postId, String uid) async {
    try {
      final userRef = _db.collection(AppConstants.usersCollection).doc(uid);
      DocumentSnapshot userSnap = await userRef.get();
      final userData = userSnap.data() as Map<String, dynamic>?;
      List savedPosts = userData?['saved_posts'] ?? [];
      
      if (savedPosts.contains(postId)) {
        await userRef.update({
          'saved_posts': FieldValue.arrayRemove([postId])
        });
      } else {
        await userRef.update({
          'saved_posts': FieldValue.arrayUnion([postId])
        });
      }
    } catch (e) {
      // Error handling
    }
  }

  @override
  Future<void> followUser(String currentUid, String targetUid) async {
    try {
      final currentUserRef = _db.collection(AppConstants.usersCollection).doc(currentUid);
      final targetUserRef = _db.collection(AppConstants.usersCollection).doc(targetUid);

      final currentUserDoc = await currentUserRef.get();
      final List following = (currentUserDoc.data() as Map<String, dynamic>?)?['following_list'] ?? [];

      if (following.contains(targetUid)) {
        await _db.runTransaction((transaction) async {
          transaction.update(currentUserRef, {
            'following_list': FieldValue.arrayRemove([targetUid]),
            'following': FieldValue.increment(-1),
          });
          transaction.update(targetUserRef, {
            'followers_list': FieldValue.arrayRemove([currentUid]),
            'followers': FieldValue.increment(-1),
          });
        });
      } else {
        await _db.runTransaction((transaction) async {
          transaction.update(currentUserRef, {
            'following_list': FieldValue.arrayUnion([targetUid]),
            'following': FieldValue.increment(1),
          });
          transaction.update(targetUserRef, {
            'followers_list': FieldValue.arrayRemove([currentUid]),
            'followers': FieldValue.increment(1),
          });
        });
      }
    } catch (e) {
      // Error handling
    }
  }

  @override
  Future<void> postComment({
    required String postId,
    required String text,
    required String uid,
    required String username,
    required String profileImage,
    String? parentId,
  }) async {
    try {
      await _db
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .collection('comments')
          .add({
        'uid': uid,
        'username': username,
        'profileImage': profileImage,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': [],
        'parentId': parentId ?? '',
      });
    } catch (e) {
      // Error handling
    }
  }
  @override
  Future<void> likePostComment(String postId, String commentId, String uid, List<String> likes) async {
    try {
      final commentRef = _db
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .collection('comments')
          .doc(commentId);
      if (likes.contains(uid)) {
        await commentRef.update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        await commentRef.update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
    } catch (e) {
      // Error handling
    }
  }
}
