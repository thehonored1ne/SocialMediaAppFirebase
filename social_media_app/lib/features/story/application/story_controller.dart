import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:social_media_app/features/auth/application/auth_controller.dart';
import 'package:social_media_app/features/profile/application/profile_controller.dart';
import 'package:social_media_app/features/story/data/repositories/firestore_story_repository.dart';
import 'package:social_media_app/features/story/domain/models/story_model.dart';

part 'story_controller.g.dart';

class SelectedMedia {
  final Uint8List bytes;
  final String name;
  final bool isVideo;
  SelectedMedia({required this.bytes, required this.name, required this.isVideo});
}

@riverpod
Stream<List<StoryModel>> activeStories(Ref ref) {
  return ref.watch(storyRepositoryProvider).getActiveStories();
}

@riverpod
Stream<Map<String, List<StoryModel>>> groupedStories(Ref ref) {
  final storiesAsync = ref.watch(activeStoriesProvider);
  
  return storiesAsync.when(
    data: (stories) {
      final Map<String, List<StoryModel>> grouped = {};
      for (var story in stories) {
        if (!grouped.containsKey(story.uid)) {
          grouped[story.uid] = [];
        }
        grouped[story.uid]!.add(story);
      }
      
      for (var uid in grouped.keys) {
        grouped[uid]!.sort((a, b) {
          if (a.timestamp == null) return 1;
          if (b.timestamp == null) return -1;
          return a.timestamp!.compareTo(b.timestamp!);
        });
      }
      
      return Stream.value(grouped);
    },
    error: (err, st) => Stream.error(err, st),
    loading: () => const Stream.empty(),
  );
}

@riverpod
class StoryController extends _$StoryController {
  @override
  FutureOr<void> build() {}

  Future<void> uploadStories(List<SelectedMedia> mediaList) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;

    final profile = ref.read(profileProvider(user.uid)).valueOrNull;
    if (profile == null) return;

    state = const AsyncLoading();
    try {
      for (var media in mediaList) {
        final url = await ref.read(storyRepositoryProvider).uploadMedia(
              fileBytes: media.bytes,
              fileName: media.name,
              isVideo: media.isVideo,
            );
        
        if (url != null) {
          final story = StoryModel(
            id: '',
            uid: user.uid,
            username: profile.username,
            profileImage: profile.profileImage,
            url: url,
            isVideo: media.isVideo,
          );
          await ref.read(storyRepositoryProvider).uploadStory(story);
        }
      }
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
