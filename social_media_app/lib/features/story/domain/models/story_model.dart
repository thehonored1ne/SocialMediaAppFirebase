class StoryModel {
  final String id;
  final String uid;
  final String username;
  final String profileImage;
  final String url;
  final bool isVideo;
  final DateTime? timestamp;

  const StoryModel({
    required this.id,
    required this.uid,
    required this.username,
    required this.profileImage,
    required this.url,
    required this.isVideo,
    this.timestamp,
  });

  StoryModel copyWith({
    String? id,
    String? uid,
    String? username,
    String? profileImage,
    String? url,
    bool? isVideo,
    DateTime? timestamp,
  }) {
    return StoryModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      username: username ?? this.username,
      profileImage: profileImage ?? this.profileImage,
      url: url ?? this.url,
      isVideo: isVideo ?? this.isVideo,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
