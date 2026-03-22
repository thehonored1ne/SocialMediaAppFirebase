class CommentModel {
  final String commentId;
  final String uid;
  final String username;
  final String profileImage;
  final String text;
  final DateTime? timestamp;
  final List<String> likes;
  final String? parentId;
  final List<CommentModel> replies;

  const CommentModel({
    required this.commentId,
    required this.uid,
    required this.username,
    required this.profileImage,
    required this.text,
    this.timestamp,
    required this.likes,
    this.parentId,
    this.replies = const [],
  });

  CommentModel copyWith({
    String? commentId,
    String? uid,
    String? username,
    String? profileImage,
    String? text,
    DateTime? timestamp,
    List<String>? likes,
    String? parentId,
    List<CommentModel>? replies,
  }) {
    return CommentModel(
      commentId: commentId ?? this.commentId,
      uid: uid ?? this.uid,
      username: username ?? this.username,
      profileImage: profileImage ?? this.profileImage,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      parentId: parentId ?? this.parentId,
      replies: replies ?? this.replies,
    );
  }
}
