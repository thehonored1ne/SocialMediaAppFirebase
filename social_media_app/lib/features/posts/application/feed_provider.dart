import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:social_media_app/features/auth/application/auth_controller.dart';
import 'package:social_media_app/features/posts/data/repositories/firestore_post_repository.dart';

part 'feed_provider.g.dart';

@riverpod
Stream<int> unreadNotificationsCount(Ref ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value(0);

  return ref.watch(postRepositoryProvider).getUnreadNotificationsCount(user.uid);
}

@riverpod
Stream<int> unreadChatsCount(Ref ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value(0);

  return ref.watch(postRepositoryProvider).getUnreadChatsCount(user.uid);
}
