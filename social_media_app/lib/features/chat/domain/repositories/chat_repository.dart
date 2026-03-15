import 'package:social_media_app/features/chat/domain/models/chat_model.dart';
import 'package:social_media_app/features/chat/domain/models/message_model.dart';

abstract class ChatRepository {
  Stream<List<ChatModel>> getChats(String uid);
  Stream<List<MessageModel>> getMessages(String chatId);
  
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String text,
    required Map<String, dynamic> usersInfo,
  });

  Future<void> markAsSeen(String chatId, String uid);
}
