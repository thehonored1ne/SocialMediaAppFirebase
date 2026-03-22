enum NotificationType {
  like,
  comment,
  follow,
  mention,
  communityRequest,
}

class NotificationModel {
  final String id;
  final String senderId;
  final String senderName;
  final String senderImage;
  final String receiverId;
  final NotificationType type;
  final String? postId;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderImage,
    required this.receiverId,
    required this.type,
    this.postId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });

  NotificationModel copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderImage,
    String? receiverId,
    NotificationType? type,
    String? postId,
    String? text,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderImage: senderImage ?? this.senderImage,
      receiverId: receiverId ?? this.receiverId,
      type: type ?? this.type,
      postId: postId ?? this.postId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
