import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:social_media_app/features/auth/application/auth_controller.dart';
import 'package:social_media_app/features/auth/domain/models/user_model.dart';
import 'package:social_media_app/features/community/domain/models/community_model.dart';
import 'package:social_media_app/features/posts/domain/models/post_model.dart';
import 'package:social_media_app/features/profile/application/profile_controller.dart';
import '../data/repositories/firestore_community_repository.dart';
import '../domain/repositories/community_repository.dart';

part 'community_controller.g.dart';

@riverpod
CommunityRepository communityRepository(Ref ref) {
  return FirestoreCommunityRepository();
}

@riverpod
Stream<List<CommunityModel>> communities(Ref ref) {
  return ref.watch(communityRepositoryProvider).getCommunities();
}

@riverpod
Stream<CommunityModel> community(Ref ref, String id) {
  return ref.watch(communityRepositoryProvider).getCommunity(id);
}

@riverpod
Stream<List<PostModel>> communityPosts(Ref ref, String communityId) {
  return ref.watch(communityRepositoryProvider).getCommunityPosts(communityId);
}

@riverpod
Future<List<UserModel>> communityMembers(Ref ref, {required String communityId, required bool isPending}) async {
  final community = await ref.watch(communityProvider(communityId).future);
  final uids = isPending ? community.pendingRequests : community.members;
  
  if (uids.isEmpty) return [];
  
  final List<UserModel> members = [];
  
  for (final uid in uids) {
    try {
      final user = await ref.read(profileProvider(uid).future);
      members.add(user);
    } catch (e) {
      members.add(UserModel(
        uid: uid,
        username: 'Unknown User',
        email: '',
        profileImage: '',
        bio: '',
        followers: 0,
        following: 0,
        savedPosts: [],
      ));
    }
  }
  
  return members;
}

@riverpod
class CommunityController extends _$CommunityController {
  @override
  FutureOr<void> build() {}

  Future<String> createCommunity({
    required String name,
    required String description,
    String? communityImage,
  }) async {
    state = const AsyncLoading();
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return '';

    final res = await ref.read(communityRepositoryProvider).createCommunity(
          name: name,
          description: description,
          adminId: user.uid,
          communityImage: communityImage,
        );
    state = const AsyncData(null);
    return res;
  }

  Future<void> requestToJoin(String communityId) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user != null) {
      await ref.read(communityRepositoryProvider).requestToJoin(communityId, user.uid);
    }
  }

  Future<void> joinCommunity(String communityId) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user != null) {
      await ref.read(communityRepositoryProvider).joinCommunity(communityId, user.uid);
    }
  }

  Future<void> approveMember(String communityId, String uid) async {
    await ref.read(communityRepositoryProvider).approveMember(communityId, uid);
  }

  Future<void> rejectMember(String communityId, String uid) async {
    await ref.read(communityRepositoryProvider).rejectMember(communityId, uid);
  }

  Future<void> kickMember(String communityId, String uid) async {
    await ref.read(communityRepositoryProvider).kickMember(communityId, uid);
  }

  Future<void> leaveCommunity(String communityId) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user != null) {
      await ref.read(communityRepositoryProvider).leaveCommunity(communityId, user.uid);
    }
  }

  Future<void> updateCommunityInfo({
    required String communityId,
    required String name,
    required String description,
    required String imageUrl,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(communityRepositoryProvider).updateCommunityInfo(
            communityId: communityId,
            name: name,
            description: description,
            imageUrl: imageUrl,
          );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
