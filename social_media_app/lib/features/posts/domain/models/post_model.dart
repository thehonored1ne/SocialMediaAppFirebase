class PostModel {
  final String uid;
  final String username;
  final String postId;
  final String imageUrl;
  final String caption;
  final DateTime? timestamp;
  final bool isVideo;
  final List<String> likes;
  final String communityId;
  final String codeSnippet;
  final String codeLanguage;

  const PostModel({
    required this.uid,
    required this.username,
    required this.postId,
    required this.imageUrl,
    required this.caption,
    this.timestamp,
    required this.isVideo,
    required this.likes,
    required this.communityId,
    this.codeSnippet = '',
    this.codeLanguage = 'dart',
  });

  PostModel copyWith({
    String? uid,
    String? username,
    String? postId,
    String? imageUrl,
    String? caption,
    DateTime? timestamp,
    bool? isVideo,
    List<String>? likes,
    String? communityId,
    String? codeSnippet,
    String? codeLanguage,
  }) {
    return PostModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      postId: postId ?? this.postId,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      timestamp: timestamp ?? this.timestamp,
      isVideo: isVideo ?? this.isVideo,
      likes: likes ?? this.likes,
      communityId: communityId ?? this.communityId,
      codeSnippet: codeSnippet ?? this.codeSnippet,
      codeLanguage: codeLanguage ?? this.codeLanguage,
    );
  }
}
