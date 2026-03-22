import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:social_media_app/core/constants/app_constants.dart';
import 'package:social_media_app/features/posts/domain/models/comment_model.dart';
import 'package:social_media_app/features/posts/domain/models/post_model.dart';
import '../../domain/repositories/reel_repository.dart';

class FirestoreReelRepository implements ReelRepository {
  final FirebaseFirestore _db;

  FirestoreReelRepository({FirebaseFirestore? db})
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
      isVideo: data['isVideo'] ?? true,
      likes: List<String>.from(data['likes'] ?? []),
      communityId: data['communityId'] ?? '',
      codeSnippet: data['codeSnippet'] ?? '',
      codeLanguage: data['codeLanguage'] ?? 'dart',
    );
  }

  CommentModel _mapToCommentModel(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    final String imageUrl = data?['profileImage'] ?? 
                           data?['profileImageUrl'] ?? 
                           data?['photoUrl'] ?? 
                           '';
    return CommentModel(
      commentId: doc.id,
      uid: data?['uid'] ?? '',
      username: data?['username'] ?? '',
      profileImage: imageUrl,
      text: data?['text'] ?? '',
      timestamp: (data?['timestamp'] as Timestamp?)?.toDate(),
      likes: List<String>.from(data?['likes'] ?? []),
      parentId: data?['parentId'] ?? '',
      replies: [],
    );
  }

  @override
  Stream<List<PostModel>> getReels() {
    return _db
        .collection(AppConstants.reelsCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map(_mapToPostModel).toList();
    });
  }

  @override
  Future<void> likeReel(String reelId, String uid, List<String> likes) async {
    final reelRef = _db.collection(AppConstants.reelsCollection).doc(reelId);
    if (likes.contains(uid)) {
      await reelRef.update({
        'likes': FieldValue.arrayRemove([uid])
      });
    } else {
      await reelRef.update({
        'likes': FieldValue.arrayUnion([uid])
      });
    }
  }

  @override
  Stream<List<CommentModel>> getReelComments(String reelId) {
    return _db
        .collection(AppConstants.reelsCollection)
        .doc(reelId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map(_mapToCommentModel).toList();
    });
  }

  @override
  Future<void> postReelComment({
    required String reelId,
    required String text,
    required String uid,
    required String username,
    required String profileImage,
    String? parentId,
  }) async {
    await _db
        .collection(AppConstants.reelsCollection)
        .doc(reelId)
        .collection('comments')
        .add({
      'text': text,
      'uid': uid,
      'username': username,
      'profileImage': profileImage,
      'timestamp': FieldValue.serverTimestamp(),
      'likes': [],
      'parentId': parentId ?? '',
    });
  }

  @override
  Future<String> uploadReel({
    required String uid,
    required String username,
    required String caption,
    required Uint8List fileBytes,
    required String fileName,
    String? profileImage,
  }) async {
    try {
      final url = Uri.parse(
        "https://api.cloudinary.com/v1_1/${AppConstants.cloudinaryCloudName}/video/upload",
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
        String videoUrl = jsonResponse['secure_url'];

        await _db.collection(AppConstants.reelsCollection).add({
          'uid': uid,
          'username': username,
          'profileImage': profileImage ?? '',
          'imageUrl': videoUrl,
          'caption': caption,
          'likes': [],
          'timestamp': FieldValue.serverTimestamp(),
          'isVideo': true,
        });
        return 'success';
      }
      return 'Upload failed';
    } catch (e) {
      return e.toString();
    }
  }
  @override
  Future<void> likeReelComment(String reelId, String commentId, String uid, List<String> likes) async {
    try {
      final commentRef = _db
          .collection(AppConstants.reelsCollection)
          .doc(reelId)
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
