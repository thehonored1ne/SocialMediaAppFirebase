class UserModel {
  final String uid;
  final String username;
  final String email;
  final String profileImage;
  final String bio;
  final int followers;
  final int following;
  final List<String> followersList;
  final List<String> followingList;
  final List<String> savedPosts;
  final String? githubUsername;
  final String? portfolioUrl;

  const UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.profileImage,
    required this.bio,
    required this.followers,
    required this.following,
    this.followersList = const [],
    this.followingList = const [],
    this.savedPosts = const [],
    this.githubUsername,
    this.portfolioUrl,
  });

  UserModel copyWith({
    String? uid,
    String? username,
    String? email,
    String? profileImage,
    String? bio,
    int? followers,
    int? following,
    List<String>? followersList,
    List<String>? followingList,
    List<String>? savedPosts,
    String? githubUsername,
    String? portfolioUrl,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      bio: bio ?? this.bio,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      followersList: followersList ?? this.followersList,
      followingList: followingList ?? this.followingList,
      savedPosts: savedPosts ?? this.savedPosts,
      githubUsername: githubUsername ?? this.githubUsername,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
    );
  }
}
