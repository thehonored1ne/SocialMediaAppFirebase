import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:social_media_app/core/constants/app_constants.dart';
import 'package:social_media_app/features/story/domain/models/story_model.dart';
import 'package:social_media_app/features/story/domain/repositories/story_repository.dart';

part 'firestore_story_repository.g.dart';

@riverpod
StoryRepository storyRepository(Ref ref) {
  return FirestoreStoryRepository();
}

class FirestoreStoryRepository implements StoryRepository {
  final FirebaseFirestore _db;

  FirestoreStoryRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  StoryModel _mapToStoryModel(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    final String imageUrl = data?['profileImage'] ?? 
                           data?['profileImageUrl'] ?? 
                           data?['photoUrl'] ?? 
                           '';
    return StoryModel(
      id: doc.id,
      uid: data?['uid'] ?? '',
      username: data?['username'] ?? '',
      profileImage: imageUrl,
      url: data?['url'] ?? '',
      isVideo: data?['isVideo'] ?? false,
      timestamp: (data?['timestamp'] as Timestamp?)?.toDate(),
    );
  }

  @override
  Stream<List<StoryModel>> getActiveStories() {
    final twentyFourHoursAgo = DateTime.now().subtract(const Duration(hours: 24));
    return _db
        .collection(AppConstants.storiesCollection)
        .where('timestamp', isGreaterThan: Timestamp.fromDate(twentyFourHoursAgo))
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_mapToStoryModel).toList());
  }

  @override
  Future<void> uploadStory(StoryModel story) async {
    await _db.collection(AppConstants.storiesCollection).add({
      'uid': story.uid,
      'username': story.username,
      'profileImage': story.profileImage,
      'url': story.url,
      'isVideo': story.isVideo,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteStory(String storyId) async {
    await _db.collection(AppConstants.storiesCollection).doc(storyId).delete();
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
}
