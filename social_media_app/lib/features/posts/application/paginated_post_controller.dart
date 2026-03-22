import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:social_media_app/features/posts/domain/models/post_model.dart';
import '../data/repositories/firestore_post_repository.dart';

part 'paginated_post_controller.g.dart';

@riverpod
class PaginatedPostController extends _$PaginatedPostController {
  static const int _pageSize = 10;
  Object? _lastDoc;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  @override
  FutureOr<List<PostModel>> build() async {
    _lastDoc = null;
    _hasMore = true;
    final response = await ref.read(postRepositoryProvider).getPaginatedPosts(limit: _pageSize);
    _lastDoc = response.lastDoc;
    _hasMore = response.hasMore;
    return response.posts;
  }

  Future<void> fetchMore() async {
    if (state.isLoading || !_hasMore) return;

    state = const AsyncLoading<List<PostModel>>().copyWithPrevious(state);

    state = await AsyncValue.guard(() async {
      final response = await ref.read(postRepositoryProvider).getPaginatedPosts(
        lastDoc: _lastDoc,
        limit: _pageSize,
      );
      
      _lastDoc = response.lastDoc;
      _hasMore = response.hasMore;
      
      final currentPosts = state.valueOrNull ?? [];
      return [...currentPosts, ...response.posts];
    });
  }

  Future<void> refresh() async {
    _lastDoc = null;
    _hasMore = true;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await ref.read(postRepositoryProvider).getPaginatedPosts(limit: _pageSize);
      _lastDoc = response.lastDoc;
      _hasMore = response.hasMore;
      return response.posts;
    });
  }
}
