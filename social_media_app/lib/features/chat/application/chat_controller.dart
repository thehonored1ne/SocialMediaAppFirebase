import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:social_media_app/features/auth/application/auth_controller.dart';
import 'package:social_media_app/features/chat/domain/models/chat_model.dart';
import 'package:social_media_app/features/chat/domain/models/message_model.dart';
import 'package:social_media_app/features/chat/domain/repositories/chat_repository.dart';
// Note: We import the provider from data layer but the controller only interacts with the interface
import 'package:social_media_app/features/chat/data/repositories/firestore_chat_repository.dart';

part 'chat_controller.g.dart';

@riverpod
Stream<List<ChatModel>> chatsStream(Ref ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return const Stream.empty();
  return ref.watch(chatRepositoryProvider).getChats(user.uid);
}

@riverpod
Stream<List<MessageModel>> messagesStream(Ref ref, String chatId) {
  return ref.watch(chatRepositoryProvider).getMessages(chatId);
}

@riverpod
class ChatController extends _$ChatController {
  @override
  FutureOr<void> build() {}

  Future<void> sendMessage({
    required String chatId,
    required String receiverId,
    required String text,
    required Map<String, dynamic> usersInfo,
  }) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;

    state = const AsyncLoading();
    try {
      await ref.read(chatRepositoryProvider).sendMessage(
            chatId: chatId,
            senderId: user.uid,
            receiverId: receiverId,
            text: text,
            usersInfo: usersInfo,
          );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsSeen(String chatId) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;

    await ref.read(chatRepositoryProvider).markAsSeen(chatId, user.uid);
  }
}
