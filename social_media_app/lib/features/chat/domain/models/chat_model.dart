class ChatModel {
  final String chatId;
  final List<String> users;
  final String lastMessage;
  final DateTime? timestamp;
  final List<String> seenBy;
  final Map<String, dynamic> usersInfo;

  const ChatModel({
    required this.chatId,
    required this.users,
    required this.lastMessage,
    this.timestamp,
    required this.seenBy,
    required this.usersInfo,
  });

  ChatModel copyWith({
    String? chatId,
    List<String>? users,
    String? lastMessage,
    DateTime? timestamp,
    List<String>? seenBy,
    Map<String, dynamic>? usersInfo,
  }) {
    return ChatModel(
      chatId: chatId ?? this.chatId,
      users: users ?? this.users,
      lastMessage: lastMessage ?? this.lastMessage,
      timestamp: timestamp ?? this.timestamp,
      seenBy: seenBy ?? this.seenBy,
      usersInfo: usersInfo ?? this.usersInfo,
    );
  }
}
