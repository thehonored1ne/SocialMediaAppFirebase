class CommunityModel {
  final String id;
  final String name;
  final String description;
  final String adminId;
  final String communityImage;
  final List<String> members;
  final List<String> pendingRequests;
  final DateTime? timestamp;

  const CommunityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.adminId,
    required this.communityImage,
    required this.members,
    required this.pendingRequests,
    this.timestamp,
  });

  CommunityModel copyWith({
    String? id,
    String? name,
    String? description,
    String? adminId,
    String? communityImage,
    List<String>? members,
    List<String>? pendingRequests,
    DateTime? timestamp,
  }) {
    return CommunityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      adminId: adminId ?? this.adminId,
      communityImage: communityImage ?? this.communityImage,
      members: members ?? this.members,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
