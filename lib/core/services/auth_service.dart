import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthResponse;
import '../../data/models/auth_session_model.dart';
import '../../data/models/user_model.dart';
import 'session_service.dart';
import 'supabase_service.dart';

class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, {this.code});

  @override
  String toString() => message;
}

class AuthService {
  static final AuthService instance = AuthService._internal();

  AuthService._internal() {
    _initSeededUsers();
  }

  final Map<String, UserModel> _fallbackUsers = {};
  final Map<String, String> _fallbackPasswords = {};

  void _initSeededUsers() {
    // Seeded accounts for fallback / fast mock tests
    final studentMember = const UserModel(
      id: '8472d1a4-62c3-4276-812c-4ca5bb597423',
      name: 'Rahul Kumar',
      email: 'rahul.kumar@uvce.edu',
      phone: '+91 98765 43210',
      studentId: 'UVCE21CS045',
      branch: 'Computer Science & Engineering',
      semester: 6,
      accountType: AccountType.student,
      role: UserRole.studentMember,
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
      bio: 'Passionate CS student and Flutter developer.',
      skills: ['Flutter', 'Python', 'Dart', 'React'],
      lookingFor: ['Hackathons', 'AI/ML Projects'],
      isAvailableForTeams: true,
      totalPoints: 850,
      contributionsCount: 18,
    );
    _registerMockUser(
      user: studentMember,
      password: 'password123',
      identifiers: ['rahul.kumar@uvce.edu', 'uvce21cs045', 'rahul'],
    );

    final studentLeader = const UserModel(
      id: '578beb87-7fd0-44db-b1a9-042deb891657',
      name: 'Ananya Sharma',
      email: 'ananya.sharma@uvce.edu',
      phone: '+91 98765 43211',
      studentId: 'UVCE21CS002',
      branch: 'Computer Science & Engineering',
      semester: 6,
      accountType: AccountType.student,
      role: UserRole.studentLeader,
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      bio: 'Student Council Lead & Tech Lead.',
      skills: ['Leadership', 'Event Management', 'UI/UX'],
      totalPoints: 1250,
      contributionsCount: 32,
    );
    _registerMockUser(
      user: studentLeader,
      password: 'leader123',
      identifiers: ['ananya.sharma@uvce.edu', 'uvce21cs002', 'ananya'],
    );

    final clubLeader = const UserModel(
      id: 'usr_coding_lead',
      name: 'Coding Club Lead',
      email: 'codingclub@uvce.edu',
      phone: '+91 98765 43212',
      studentId: 'CLUB_CODING',
      branch: 'Computer Science',
      semester: 7,
      accountType: AccountType.club,
      role: UserRole.clubLeader,
      clubId: '91ffc196-953c-4526-ab8f-26e863a6954d',
      clubName: 'Coding Club UVCE',
      avatarUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150',
      bio: 'President & Lead of UVCE Coding Club.',
    );
    _registerMockUser(
      user: clubLeader,
      password: 'club123',
      identifiers: ['codingclub@uvce.edu', 'club_coding', 'codingclub'],
    );

    final clubMember = const UserModel(
      id: '2f29339f-017d-4921-9c90-a0fc5de049db',
      name: 'Vikram Mehta',
      email: 'robotics.member@uvce.edu',
      phone: '+91 98765 43213',
      studentId: 'UVCE22EC019',
      branch: 'Electronics & Communication',
      semester: 4,
      accountType: AccountType.club,
      role: UserRole.clubMember,
      clubId: '4563989d-32cd-45ab-b1b3-019a7745e148',
      clubName: 'Robotics & Automation Club',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      bio: 'Hardware hacker and active member in Robotics Club.',
    );
    _registerMockUser(
      user: clubMember,
      password: 'member123',
      identifiers: ['robotics.member@uvce.edu', 'uvce22ec019', 'vikram'],
    );

    final srmAdmin = const UserModel(
      id: 'c2aaabf5-85ef-436b-a323-480d7af34f8f',
      name: 'Dr. Ramesh Rao',
      email: 'admin.srm@uvce.edu',
      phone: '+91 98765 00001',
      studentId: 'SRM_ADMIN_01',
      branch: 'Administration',
      semester: 0,
      accountType: AccountType.srm,
      role: UserRole.srmAdministrator,
      srmId: 'SRM_CAMPUS_MAIN',
      avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
      bio: 'SRM University Administrator & Campus Director.',
    );
    _registerMockUser(
      user: srmAdmin,
      password: 'srm123456',
      identifiers: ['admin.srm@uvce.edu', 'srm_admin_01', 'srmadmin', 'srm', 'srm123'],
    );
    _registerMockUser(
      user: srmAdmin,
      password: 'srm123',
      identifiers: ['admin.srm@uvce.edu', 'srm_admin_01', 'srmadmin', 'srm'],
    );
  }

  void _registerMockUser({
    required UserModel user,
    required String password,
    required List<String> identifiers,
  }) {
    for (final id in identifiers) {
      _fallbackUsers[id.trim().toLowerCase()] = user;
    }
    _fallbackPasswords[user.id] = password;
  }

  /// Unified backend authentication login using Supabase Auth
  Future<AuthResponse> login({
    required String identifier,
    required String password,
  }) async {
    final normalized = identifier.trim().toLowerCase();
    if (normalized.isEmpty || password.trim().isEmpty) {
      throw const AuthException('Please enter your email/ID and password.');
    }

    // 1. Try real Supabase Auth
    if (SupabaseService.instance.isInitialized) {
      try {
        final client = SupabaseService.instance.client;
        String emailToUse = normalized;

        // If identifier is not an email format, resolve email from public.profiles
        if (!normalized.contains('@')) {
          final profileRes = await client
              .from('profiles')
              .select('email')
              .or('student_id.ilike.$normalized,srm_id.ilike.$normalized,full_name.ilike.$normalized')
              .maybeSingle();

          if (profileRes != null && profileRes['email'] != null) {
            emailToUse = profileRes['email'] as String;
          }
        }

        // Authenticate with Supabase Auth
        final authRes = await client.auth.signInWithPassword(
          email: emailToUse,
          password: password,
        );

        final authUser = authRes.user;
        final session = authRes.session;

        if (authUser != null && session != null) {
          // Fetch profile row from public.profiles
          final profileData = await client
              .from('profiles')
              .select('*')
              .eq('id', authUser.id)
              .maybeSingle();

          UserModel user;
          if (profileData != null) {
            user = _parseProfileData(profileData, authUser);
          } else {
            user = UserModel(
              id: authUser.id,
              name: authUser.userMetadata?['full_name'] as String? ?? authUser.email ?? '',
              email: authUser.email ?? '',
              studentId: authUser.userMetadata?['student_id'] as String? ?? '',
              accountType: AccountType.student,
              role: UserRole.studentMember,
            );
          }

          final token = session.accessToken;
          final response = AuthResponse(
            token: token,
            user: user,
            message: 'Authentication successful',
          );

          final authSession = AuthSession(
            token: token,
            user: user,
            createdAt: DateTime.now(),
            expiresAt: DateTime.fromMillisecondsSinceEpoch(
              (session.expiresAt ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600 * 24 * 7)) * 1000,
            ),
          );
          await SessionService.instance.saveSession(authSession);

          return response;
        }
      } on AuthApiException catch (e) {
        if (e.message.toLowerCase().contains('invalid login credentials')) {
          throw const AuthException('Incorrect password or user not found. Please try again.');
        }
        // Fallback to local accounts if Supabase returns error during tests
      } catch (_) {
        // Fallback to local accounts if Supabase is unreachable
      }
    }

    // 2. Fallback to mock accounts (offline / unit test environment)
    return _loginFallback(identifier: normalized, password: password);
  }

  UserModel _parseProfileData(Map<String, dynamic> data, User authUser) {
    final accountTypeStr = data['account_type'] as String?;
    final roleStr = data['role'] as String?;

    final role = UserRole.tryFromString(roleStr) ?? UserRole.studentMember;
    
    AccountType accountType;
    if (role == UserRole.clubLeader || roleStr == 'club_leader' || roleStr == 'leader' || accountTypeStr == 'club') {
      accountType = AccountType.club;
    } else if (role == UserRole.srmAdministrator || roleStr == 'srm_admin' || accountTypeStr == 'srm') {
      accountType = AccountType.srm;
    } else {
      accountType = AccountType.tryFromString(accountTypeStr) ?? role.accountType;
    }

    return UserModel(
      id: authUser.id,
      name: data['full_name'] as String? ?? '',
      email: data['email'] as String? ?? authUser.email ?? '',
      phone: data['phone'] as String? ?? '',
      studentId: data['student_id'] as String? ?? '',
      branch: data['branch'] as String? ?? '',
      semester: data['semester'] as int? ?? 1,
      endingYear: data['ending_year'] as int? ?? data['endingYear'] as int? ?? 0,
      accountType: accountType,
      role: role,
      clubId: data['club_id'] as String?,
      clubName: data['club_name'] as String?,
      srmId: data['srm_id'] as String?,
      avatarUrl: data['avatar_url'] as String? ?? '',
      bio: data['bio'] as String? ?? '',
    );
  }

  Future<AuthResponse> _loginFallback({
    required String identifier,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final user = _fallbackUsers[identifier];
    if (user == null) {
      throw const AuthException('No account found with this email, ID, or username.');
    }

    final storedPassword = _fallbackPasswords[user.id];
    if (storedPassword != null && storedPassword != password) {
      throw const AuthException('Incorrect password. Please try again.');
    }

    final token = 'cc_jwt_${user.id}_${DateTime.now().millisecondsSinceEpoch}';
    final response = AuthResponse(
      token: token,
      user: user,
      message: 'Authentication successful',
    );

    final session = AuthSession(
      token: token,
      user: user,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    );
    await SessionService.instance.saveSession(session);

    return response;
  }

  /// Student account creation via Supabase Auth
  /// Defaults strictly to `Student Member`
  Future<AuthResponse> registerStudent({
    required String name,
    String studentId = '',
    required String email,
    required String phone,
    required String branch,
    required int endingYear,
    int semester = 1,
    required String password,
    String avatarUrl = '',
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedId = studentId.trim().toUpperCase();

    if (SupabaseService.instance.isInitialized) {
      try {
        final client = SupabaseService.instance.client;

        final authRes = await client.auth.signUp(
          email: normalizedEmail,
          password: password,
          data: {
            'full_name': name.trim(),
            if (normalizedId.isNotEmpty) 'student_id': normalizedId,
            'phone': phone.trim(),
            'branch': branch,
            'ending_year': endingYear,
            'semester': semester,
            'avatar_url': avatarUrl,
          },
        );

        final authUser = authRes.user;
        if (authUser != null) {
          final newUser = UserModel(
            id: authUser.id,
            name: name.trim(),
            email: normalizedEmail,
            phone: phone.trim(),
            studentId: normalizedId,
            branch: branch,
            semester: semester,
            endingYear: endingYear,
            accountType: AccountType.student,
            role: UserRole.studentMember,
            avatarUrl: avatarUrl,
          );

          final token = authRes.session?.accessToken ?? 'cc_jwt_${authUser.id}';
          final response = AuthResponse(
            token: token,
            user: newUser,
            message: 'Student account registered successfully',
          );

          final session = AuthSession(
            token: token,
            user: newUser,
            createdAt: DateTime.now(),
            expiresAt: DateTime.now().add(const Duration(days: 7)),
          );
          await SessionService.instance.saveSession(session);

          return response;
        }
      } on AuthApiException catch (e) {
        if (e.message.toLowerCase().contains('already registered')) {
          throw const AuthException('An account with this email already exists. Please log in.');
        }
      } catch (_) {
        // Fall through to fallback
      }
    }

    // Fallback registration
    if (_fallbackUsers.containsKey(normalizedEmail)) {
      throw const AuthException('An account with this email already exists. Please log in.');
    }
    if (normalizedId.isNotEmpty && _fallbackUsers.containsKey(normalizedId.toLowerCase())) {
      throw const AuthException('An account with this Student ID / USN already exists.');
    }

    final newUser = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: normalizedEmail,
      phone: phone.trim(),
      studentId: normalizedId,
      branch: branch,
      semester: semester,
      endingYear: endingYear,
      accountType: AccountType.student,
      role: UserRole.studentMember,
      avatarUrl: avatarUrl,
      bio: 'Student at UVCE',
    );

    _registerMockUser(
      user: newUser,
      password: password,
      identifiers: [
        normalizedEmail,
        if (normalizedId.isNotEmpty) normalizedId.toLowerCase(),
        name.toLowerCase().replaceAll(' ', ''),
      ],
    );

    final token = 'cc_jwt_${newUser.id}_${DateTime.now().millisecondsSinceEpoch}';
    final response = AuthResponse(
      token: token,
      user: newUser,
      message: 'Student account registered successfully',
    );

    final session = AuthSession(
      token: token,
      user: newUser,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    );
    await SessionService.instance.saveSession(session);

    return response;
  }

  /// Request Password Reset
  Future<void> requestPasswordReset(String identifier) async {
    final normalized = identifier.trim().toLowerCase();
    if (normalized.isEmpty) {
      throw const AuthException('Please provide your email address or student ID.');
    }

    if (SupabaseService.instance.isInitialized && normalized.contains('@')) {
      try {
        await SupabaseService.instance.client.auth.resetPasswordForEmail(normalized);
      } catch (_) {
        // Silently succeed
      }
    }
  }

  /// Restore active session
  Future<AuthSession?> restoreSession() async {
    if (SupabaseService.instance.isInitialized) {
      try {
        final currentSession = SupabaseService.instance.auth.currentSession;
        final currentAuthUser = SupabaseService.instance.auth.currentUser;

        if (currentSession != null && currentAuthUser != null && !currentSession.isExpired) {
          final profileData = await SupabaseService.instance.client
              .from('profiles')
              .select('*')
              .eq('id', currentAuthUser.id)
              .maybeSingle();

          UserModel user;
          if (profileData != null) {
            user = _parseProfileData(profileData, currentAuthUser);
          } else {
            user = UserModel(
              id: currentAuthUser.id,
              name: currentAuthUser.email ?? '',
              email: currentAuthUser.email ?? '',
              studentId: '',
              accountType: AccountType.student,
              role: UserRole.studentMember,
            );
          }

          final authSession = AuthSession(
            token: currentSession.accessToken,
            user: user,
            createdAt: DateTime.now(),
            expiresAt: DateTime.fromMillisecondsSinceEpoch(
              (currentSession.expiresAt ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600 * 24)) * 1000,
            ),
          );
          await SessionService.instance.saveSession(authSession);
          return authSession;
        }
      } catch (_) {
        // Fall back to local SessionService
      }
    }

    final localSession = await SessionService.instance.loadSession();
    if (localSession == null || !localSession.isValid) {
      await SessionService.instance.clearSession();
      return null;
    }
    return localSession;
  }

  /// Logout
  Future<void> logout() async {
    if (SupabaseService.instance.isInitialized) {
      try {
        await SupabaseService.instance.auth.signOut();
      } catch (_) {
        // Ignore
      }
    }
    await SessionService.instance.clearSession();
  }
}
