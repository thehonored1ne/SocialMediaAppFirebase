import 'dart:typed_data';
import '../models/story_model.dart';

abstract class StoryRepository {
  Stream<List<StoryModel>> getActiveStories();
  Future<void> uploadStory(StoryModel story);
  Future<void> deleteStory(String storyId);
  
  Future<String?> uploadMedia({
    required Uint8List fileBytes,
    required String fileName,
    required bool isVideo,
  });
}
