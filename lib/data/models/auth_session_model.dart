import 'user_model.dart';

class AuthResponse {
  final String token;
  final UserModel user;
  final String? message;

  const AuthResponse({
    required this.token,
    required this.user,
    this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
      if (message != null) 'message': message,
    };
  }

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String? ?? '',
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      message: json['message'] as String?,
    );
  }
}

class AuthSession {
  final String token;
  final UserModel user;
  final DateTime createdAt;
  final DateTime expiresAt;

  const AuthSession({
    required this.token,
    required this.user,
    required this.createdAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isValid => token.isNotEmpty && !isExpired;

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      token: json['token'] as String? ?? '',
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : DateTime.now().add(const Duration(days: 7)),
    );
  }

  AuthSession copyWith({
    String? token,
    UserModel? user,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return AuthSession(
      token: token ?? this.token,
      user: user ?? this.user,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
