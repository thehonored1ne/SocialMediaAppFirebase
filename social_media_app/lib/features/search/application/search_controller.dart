import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:social_media_app/features/auth/domain/models/user_model.dart';
import 'package:social_media_app/features/community/domain/models/community_model.dart';
import 'package:social_media_app/features/search/data/repositories/firestore_search_repository.dart';
import 'package:social_media_app/features/search/domain/repositories/search_repository.dart';

part 'search_controller.g.dart';

@riverpod
SearchRepository searchRepository(Ref ref) {
  return FirestoreSearchRepository();
}

@riverpod
Stream<List<UserModel>> suggestedUsers(Ref ref) {
  return ref.watch(searchRepositoryProvider).getSuggestedUsers();
}

@riverpod
Stream<List<CommunityModel>> browseCommunities(Ref ref) {
  return ref.watch(searchRepositoryProvider).getCommunities();
}

@riverpod
class SearchController extends _$SearchController {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }
}

@riverpod
Stream<List<UserModel>> searchUsersResults(Ref ref) {
  final query = ref.watch(searchControllerProvider);
  if (query.isEmpty) return Stream.value([]);
  return ref.watch(searchRepositoryProvider).searchUsers(query);
}

@riverpod
Stream<List<CommunityModel>> searchCommunitiesResults(Ref ref) {
  final query = ref.watch(searchControllerProvider);
  if (query.isEmpty) return Stream.value([]);
  return ref.watch(searchRepositoryProvider).searchCommunities(query);
}
