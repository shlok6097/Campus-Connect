enum UserRole { student, organizer }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String studentId; // USN
  final String branch;
  final int semester;
  final UserRole role;
  final String avatarUrl;
  final String bio;
  final List<String> skills;
  final List<String> lookingFor;
  final bool isAvailableForTeams;
  final int totalPoints;
  final int contributionsCount;
  final List<UserAchievement> achievements;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    required this.studentId,
    required this.branch,
    required this.semester,
    this.role = UserRole.student,
    this.avatarUrl = '',
    this.bio = '',
    this.skills = const [],
    this.lookingFor = const [],
    this.isAvailableForTeams = true,
    this.totalPoints = 0,
    this.contributionsCount = 0,
    this.achievements = const [],
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? studentId,
    String? branch,
    int? semester,
    UserRole? role,
    String? avatarUrl,
    String? bio,
    List<String>? skills,
    List<String>? lookingFor,
    bool? isAvailableForTeams,
    int? totalPoints,
    int? contributionsCount,
    List<UserAchievement>? achievements,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      studentId: studentId ?? this.studentId,
      branch: branch ?? this.branch,
      semester: semester ?? this.semester,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      lookingFor: lookingFor ?? this.lookingFor,
      isAvailableForTeams: isAvailableForTeams ?? this.isAvailableForTeams,
      totalPoints: totalPoints ?? this.totalPoints,
      contributionsCount: contributionsCount ?? this.contributionsCount,
      achievements: achievements ?? this.achievements,
    );
  }
}

class UserAchievement {
  final String title;
  final String issuer;
  final String date;
  final String icon;

  const UserAchievement({
    required this.title,
    required this.issuer,
    required this.date,
    this.icon = 'trophy',
  });
}
