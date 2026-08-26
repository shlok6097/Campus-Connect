enum ProjectStage { idea, planning, development, testing, completed }

enum FileType { pdf, video, code, document, other }

class SharedFileItem {
  final String id;
  final String title;
  final FileType fileType;
  final String fileSize;
  final String updatedTime;
  final String downloadUrl;

  const SharedFileItem({
    required this.id,
    required this.title,
    required this.fileType,
    required this.fileSize,
    required this.updatedTime,
    required this.downloadUrl,
  });
}

class TeamMemberItem {
  final String id;
  final String name;
  final String role; // e.g. "Leader", "UI/UX Designer", "Backend Lead", "ML Engineer"
  final String avatarUrl;
  final String branch;
  final int semester;
  final bool isLeader;

  const TeamMemberItem({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.branch,
    required this.semester,
    this.isLeader = false,
  });
}

class TeamActivityItem {
  final String id;
  final String userName;
  final String userAvatar;
  final String actionText;
  final String timeAgo;

  const TeamActivityItem({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.actionText,
    required this.timeAgo,
  });
}

class ProjectModel {
  final String id;
  final String title;
  final String problem;
  final String solution;
  final String category;
  final ProjectStage stage;
  final List<String> techStack;
  final List<String> lookingForRoles;
  final bool isPublic;
  final String imageUrl;

  const ProjectModel({
    required this.id,
    required this.title,
    required this.problem,
    required this.solution,
    this.category = 'AI / ML',
    this.stage = ProjectStage.development,
    this.techStack = const [],
    this.lookingForRoles = const [],
    this.isPublic = true,
    this.imageUrl = '',
  });

  ProjectModel copyWith({
    String? id,
    String? title,
    String? problem,
    String? solution,
    String? category,
    ProjectStage? stage,
    List<String>? techStack,
    List<String>? lookingForRoles,
    bool? isPublic,
    String? imageUrl,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      title: title ?? this.title,
      problem: problem ?? this.problem,
      solution: solution ?? this.solution,
      category: category ?? this.category,
      stage: stage ?? this.stage,
      techStack: techStack ?? this.techStack,
      lookingForRoles: lookingForRoles ?? this.lookingForRoles,
      isPublic: isPublic ?? this.isPublic,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class TeamModel {
  final String id;
  final String name;
  final String eventName;
  final String eventId;
  final String leaderName;
  final String leaderId;
  final List<TeamMemberItem> members;
  final ProjectModel? project;
  final List<SharedFileItem> sharedFiles;
  final List<TeamActivityItem> recentActivity;

  const TeamModel({
    required this.id,
    required this.name,
    required this.eventName,
    required this.eventId,
    required this.leaderName,
    required this.leaderId,
    this.members = const [],
    this.project,
    this.sharedFiles = const [],
    this.recentActivity = const [],
  });

  int get memberCount => members.length;
}
