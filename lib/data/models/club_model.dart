enum ClubCategory { technical, cultural, sports, creative, academic, others }

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
  final String email;
  final String usn;
  final String role; // e.g. "Club Leader", "Event Coordinator", "Technical Lead", "Core Member", "Member"
  final String branch;
  final int semester;
  final String avatarUrl;
  final String joinedDate;
  final bool isManager;
  final List<String> privileges;

  const ClubMemberItem({
    required this.id,
    required this.name,
    this.email = '',
    this.usn = '',
    required this.role,
    required this.branch,
    required this.semester,
    required this.avatarUrl,
    required this.joinedDate,
    this.isManager = false,
    this.privileges = const ['view_events'],
  });

  bool get canManageEvents =>
      isManager ||
      privileges.contains('manage_events') ||
      role.toLowerCase().contains('coordinator') ||
      role.toLowerCase().contains('leader');

  bool get canViewResponses =>
      isManager ||
      privileges.contains('view_responses') ||
      canManageEvents;

  bool get canPublish =>
      isManager ||
      privileges.contains('publish_content') ||
      role.toLowerCase().contains('lead') ||
      role.toLowerCase().contains('leader');

  bool get canManageMembers =>
      isManager ||
      privileges.contains('manage_members') ||
      role.toLowerCase().contains('leader');

  bool get canCheckIn =>
      isManager ||
      privileges.contains('checkin_attendees') ||
      canManageEvents;

  ClubMemberItem copyWith({
    String? id,
    String? name,
    String? email,
    String? usn,
    String? role,
    String? branch,
    int? semester,
    String? avatarUrl,
    String joinedDate = '',
    bool? isManager,
    List<String>? privileges,
  }) {
    return ClubMemberItem(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      usn: usn ?? this.usn,
      role: role ?? this.role,
      branch: branch ?? this.branch,
      semester: semester ?? this.semester,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      joinedDate: joinedDate.isNotEmpty ? joinedDate : this.joinedDate,
      isManager: isManager ?? this.isManager,
      privileges: privileges ?? this.privileges,
    );
  }
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

  factory ClubModel.fromJson(Map<String, dynamic> json, {String currentUserId = ''}) {
    final categoryStr = (json['category'] ?? '').toString().toLowerCase();
    ClubCategory category = ClubCategory.technical;
    for (final cat in ClubCategory.values) {
      if (cat.name == categoryStr) {
        category = cat;
        break;
      }
    }

    final membersList = <ClubMemberItem>[];
    bool isJoined = false;
    String userRole = 'None';

    final membersRaw = json['club_members'] as List<dynamic>?;
    if (membersRaw != null) {
      for (final m in membersRaw) {
        if (m is Map<String, dynamic>) {
          final userId = (m['user_id'] ?? '').toString();
          final rawRole = (m['role'] ?? 'member').toString();
          final profile = m['profiles'] as Map<String, dynamic>?;
          final name = (profile?['full_name'] ?? profile?['name'] ?? 'Member').toString();
          final email = (profile?['email'] ?? '').toString();
          final usn = (profile?['usn'] ?? '').toString();
          final branch = (profile?['branch'] ?? '').toString();
          final semester = profile?['semester'] as int? ?? 1;
          final avatarUrl = (profile?['avatar_url'] ?? '').toString();

          final isMgr = rawRole == 'club_leader' || rawRole == 'leader' || rawRole == 'Club Leader';
          final formattedRole = isMgr
              ? 'Club Leader'
              : rawRole.replaceAll('_', ' ').split(' ').map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '').join(' ');

          List<String> privileges = [];
          if (m['privileges'] is List) {
            privileges = (m['privileges'] as List).map((e) => e.toString()).toList();
          } else if (isMgr) {
            privileges = ['manage_events', 'view_responses', 'publish_content', 'manage_members', 'checkin_attendees'];
          } else {
            privileges = ['view_events'];
          }

          membersList.add(ClubMemberItem(
            id: userId,
            name: name,
            email: email,
            usn: usn,
            role: formattedRole.isNotEmpty ? formattedRole : (isMgr ? 'Club Leader' : 'Member'),
            branch: branch,
            semester: semester,
            avatarUrl: avatarUrl,
            joinedDate: m['joined_at'] != null ? m['joined_at'].toString().split('T').first : 'Recently',
            isManager: isMgr,
            privileges: privileges,
          ));

          if (currentUserId.isNotEmpty && userId == currentUserId) {
            isJoined = true;
            userRole = isMgr ? 'Leader' : 'Member';
          }
        }
      }
    }

    return ClubModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      tagline: (json['tagline'] ?? json['description'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      category: category,
      logoUrl: (json['logo_url'] ?? json['logoUrl'] ?? '').toString(),
      memberCount: membersList.isNotEmpty ? membersList.length : (json['member_count'] as int? ?? 0),
      isUserJoined: isJoined,
      userRole: userRole,
      members: membersList,
    );
  }
}
