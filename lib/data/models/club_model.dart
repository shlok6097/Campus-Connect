enum ClubCategory { technical, cultural, sports, creative, academic }

class ClubActivityItem {
  final String id;
  final String title;
  final String description;
  final String month; // e.g. "AUG"
  final String day;   // e.g. "28"
  final String type;

  const ClubActivityItem({
    required this.id,
    required this.title,
    required this.description,
    required this.month,
    required this.day,
    this.type = 'Workshop',
  });
}

class ClubMemberItem {
  final String id;
  final String name;
  final String role; // e.g. "Club President", "Event Manager", "Member", "Co-Lead"
  final String branch;
  final int semester;
  final String avatarUrl;
  final String joinedDate;
  final bool isManager;

  const ClubMemberItem({
    required this.id,
    required this.name,
    required this.role,
    required this.branch,
    required this.semester,
    required this.avatarUrl,
    required this.joinedDate,
    this.isManager = false,
  });
}

class ClubModel {
  final String id;
  final String name;
  final String tagline;
  final String description;
  final ClubCategory category;
  final String logoUrl;
  final int memberCount;
  final bool isUserJoined;
  final String userRole; // e.g. "Member", "Co-Lead", "None"
  final String buildingProjectTitle;
  final String buildingProjectDesc;
  final List<String> buildingProjectTech;
  final List<ClubActivityItem> upcomingActivities;
  final List<String> achievements;
  final List<ClubMemberItem> members;

  const ClubModel({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.category,
    required this.logoUrl,
    this.memberCount = 0,
    this.isUserJoined = false,
    this.userRole = 'None',
    this.buildingProjectTitle = '',
    this.buildingProjectDesc = '',
    this.buildingProjectTech = const [],
    this.upcomingActivities = const [],
    this.achievements = const [],
    this.members = const [],
  });

  ClubModel copyWith({
    String? id,
    String? name,
    String? tagline,
    String? description,
    ClubCategory? category,
    String? logoUrl,
    int? memberCount,
    bool? isUserJoined,
    String? userRole,
    String? buildingProjectTitle,
    String? buildingProjectDesc,
    List<String>? buildingProjectTech,
    List<ClubActivityItem>? upcomingActivities,
    List<String>? achievements,
    List<ClubMemberItem>? members,
  }) {
    return ClubModel(
      id: id ?? this.id,
      name: name ?? this.name,
      tagline: tagline ?? this.tagline,
      description: description ?? this.description,
      category: category ?? this.category,
      logoUrl: logoUrl ?? this.logoUrl,
      memberCount: memberCount ?? this.memberCount,
      isUserJoined: isUserJoined ?? this.isUserJoined,
      userRole: userRole ?? this.userRole,
      buildingProjectTitle: buildingProjectTitle ?? this.buildingProjectTitle,
      buildingProjectDesc: buildingProjectDesc ?? this.buildingProjectDesc,
      buildingProjectTech: buildingProjectTech ?? this.buildingProjectTech,
      upcomingActivities: upcomingActivities ?? this.upcomingActivities,
      achievements: achievements ?? this.achievements,
      members: members ?? this.members,
    );
  }
}
