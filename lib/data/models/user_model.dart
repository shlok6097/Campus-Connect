enum AccountType {
  student('student', 'Student'),
  club('club', 'Club'),
  srm('srm', 'SRM');

  final String value;
  final String displayName;

  const AccountType(this.value, this.displayName);

  static AccountType fromString(String? type) {
    if (type == null) return AccountType.student;
    for (final t in AccountType.values) {
      if (t.value == type || t.name == type) {
        return t;
      }
    }
    return AccountType.student;
  }

  static AccountType? tryFromString(String? type) {
    if (type == null) return null;
    for (final t in AccountType.values) {
      if (t.value == type || t.name == type) {
        return t;
      }
    }
    return null;
  }
}

enum UserRole {
  studentMember('student_member', 'Student Member', AccountType.student),
  studentLeader('student_leader', 'Student Leader', AccountType.student),
  clubMember('club_member', 'Club Member', AccountType.club),
  clubLeader('club_leader', 'Club Leader', AccountType.club),
  srmAdministrator('srm_administrator', 'SRM Administrator', AccountType.srm);

  final String value;
  final String displayName;
  final AccountType accountType;

  const UserRole(this.value, this.displayName, this.accountType);

  static UserRole fromString(String? role) {
    if (role == null) {
      throw ArgumentError('Role cannot be null');
    }
    for (final r in UserRole.values) {
      if (r.value == role ||
          r.name == role ||
          r.displayName.toLowerCase() == role.toLowerCase()) {
        return r;
      }
    }
    // Backward compatibility & backend aliases
    if (role == 'student') return UserRole.studentMember;
    if (role == 'organizer') return UserRole.clubLeader;
    if (role == 'srm_admin' || role == 'srm_administrator') return UserRole.srmAdministrator;
    throw ArgumentError('Unsupported or invalid role: $role');
  }

  static UserRole? tryFromString(String? role) {
    if (role == null) return null;
    try {
      return fromString(role);
    } catch (_) {
      return null;
    }
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String studentId; // USN or Admin ID
  final String branch;
  final int semester;
  final int endingYear;
  final AccountType accountType;
  final UserRole role;
  final String? clubId;
  final String? clubName;
  final String? srmId;
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
    this.studentId = '',
    this.branch = '',
    this.semester = 1,
    this.endingYear = 0,
    this.accountType = AccountType.student,
    this.role = UserRole.studentMember,
    this.clubId,
    this.clubName,
    this.srmId,
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
    int? endingYear,
    AccountType? accountType,
    UserRole? role,
    String? clubId,
    String? clubName,
    String? srmId,
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
      endingYear: endingYear ?? this.endingYear,
      accountType: accountType ?? this.accountType,
      role: role ?? this.role,
      clubId: clubId ?? this.clubId,
      clubName: clubName ?? this.clubName,
      srmId: srmId ?? this.srmId,
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

  bool get isClubLeader =>
      role == UserRole.clubLeader ||
      accountType == AccountType.club ||
      (clubId != null && clubId!.isNotEmpty && role == UserRole.clubLeader);

  bool get isSrmAdmin =>
      role == UserRole.srmAdministrator ||
      accountType == AccountType.srm;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'studentId': studentId,
      'branch': branch,
      'semester': semester,
      'endingYear': endingYear,
      'ending_year': endingYear,
      'accountType': accountType.value,
      'role': role.value,
      'clubId': clubId,
      'clubName': clubName,
      'srmId': srmId,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'skills': skills,
      'lookingFor': lookingFor,
      'isAvailableForTeams': isAvailableForTeams,
      'totalPoints': totalPoints,
      'contributionsCount': contributionsCount,
      'achievements': achievements.map((a) => a.toJson()).toList(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final roleStr = json['role']?.toString();
    final role = UserRole.tryFromString(roleStr) ?? UserRole.studentMember;
    final accountTypeStr = (json['accountType'] ?? json['account_type'])?.toString();
    final accountType = AccountType.tryFromString(accountTypeStr) ?? role.accountType;

    final semVal = json['semester'];
    final semInt = semVal is int
        ? semVal
        : int.tryParse(semVal?.toString() ?? '1') ?? 1;

    final endingVal = json['endingYear'] ?? json['ending_year'] ?? json['graduation_year'];
    final endingInt = endingVal is int
        ? endingVal
        : int.tryParse(endingVal?.toString() ?? '0') ?? 0;

    List<String> parseStringList(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString()).toList();
      }
      return const [];
    }

    return UserModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? json['full_name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? json['phone_number'] ?? '').toString(),
      studentId: (json['studentId'] ?? json['student_id'] ?? json['usn'] ?? '').toString(),
      branch: (json['branch'] ?? json['department'] ?? '').toString(),
      semester: semInt,
      endingYear: endingInt,
      accountType: accountType,
      role: role,
      clubId: (json['clubId'] ?? json['club_id'])?.toString(),
      clubName: (json['clubName'] ?? json['club_name'])?.toString(),
      srmId: (json['srmId'] ?? json['srm_id'])?.toString(),
      avatarUrl: (json['avatarUrl'] ?? json['avatar_url'] ?? '').toString(),
      bio: (json['bio'] ?? '').toString(),
      skills: parseStringList(json['skills']),
      lookingFor: parseStringList(json['lookingFor'] ?? json['looking_for']),
      isAvailableForTeams: json['isAvailableForTeams'] as bool? ??
          json['is_available_for_teams'] as bool? ??
          true,
      totalPoints: json['totalPoints'] is int
          ? json['totalPoints'] as int
          : json['total_points'] is int
              ? json['total_points'] as int
              : 0,
      contributionsCount: json['contributionsCount'] is int
          ? json['contributionsCount'] as int
          : json['contributions_count'] is int
              ? json['contributions_count'] as int
              : 0,
      achievements: (json['achievements'] is List)
          ? (json['achievements'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => UserAchievement.fromJson(e))
              .toList()
          : const [],
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

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'issuer': issuer,
      'date': date,
      'icon': icon,
    };
  }

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      title: json['title'] as String? ?? '',
      issuer: json['issuer'] as String? ?? '',
      date: json['date'] as String? ?? '',
      icon: json['icon'] as String? ?? 'trophy',
    );
  }
}
