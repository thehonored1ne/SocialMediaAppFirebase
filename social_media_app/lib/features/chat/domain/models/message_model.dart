class MessageModel {
  final String messageId;
  final String senderId;
  final String text;
  final DateTime? timestamp;
  final bool isRead;

  const MessageModel({
    required this.messageId,
    required this.senderId,
    required this.text,
    this.timestamp,
    this.isRead = false,
  });

  MessageModel copyWith({
    String? messageId,
    String? senderId,
    String? text,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return MessageModel(
      messageId: messageId ?? this.messageId,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
