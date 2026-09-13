import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../data/models/auth_session_model.dart';
import '../../data/models/user_model.dart';

class AuthController extends ChangeNotifier {
  static final AuthController instance = AuthController._internal();

  static final UserModel _guestUser = UserModel(
    id: '',
    name: '',
    email: '',
    accountType: AccountType.student,
    role: UserRole.studentMember,
  );

  AuthController._internal();

  UserModel? _currentUser;
  AuthSession? _currentSession;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  UserModel get currentUser => _currentUser ?? _guestUser;
  AuthSession? get currentSession => _currentSession;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  bool get isAuthenticated => _currentUser != null && _currentUser!.id.isNotEmpty && (_currentSession?.isValid ?? true);
  bool get isLoggedIn => isAuthenticated;

  AccountType get accountType => currentUser.accountType;
  UserRole get currentRole => currentUser.role;

  bool get isStudent => accountType == AccountType.student;
  bool get isClub => accountType == AccountType.club;
  bool get isSrm => accountType == AccountType.srm;

  // Specific role helpers
  bool get isStudentMember => currentRole == UserRole.studentMember;
  bool get isStudentLeader => currentRole == UserRole.studentLeader;
  bool get isClubMember => currentRole == UserRole.clubMember;
  bool get isClubLeader => currentRole == UserRole.clubLeader;
  bool get isSrmAdministrator => currentRole == UserRole.srmAdministrator;

  // Legacy compatibility helpers
  bool get isOrganizer => isClub;
  String get currentClubOrRole =>
      currentUser.clubName ?? currentUser.role.displayName;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  /// Unified Login: Frontend sends credentials, backend returns role and account type
  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await AuthService.instance.login(
        identifier: identifier,
        password: password,
      );

      _currentUser = response.user;
      _currentSession = AuthSession(
        token: response.token,
        user: response.user,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'An unexpected error occurred during login. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Student Registration: Automatically assigns role `Student Member`
  Future<bool> registerStudent({
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
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await AuthService.instance.registerStudent(
        name: name,
        studentId: studentId,
        email: email,
        phone: phone,
        branch: branch,
        endingYear: endingYear,
        semester: semester,
        password: password,
        avatarUrl: avatarUrl,
      );

      _currentUser = response.user;
      _currentSession = AuthSession(
        token: response.token,
        user: response.user,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      );

      _successMessage = 'Account created successfully!';
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to register student account. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Restore session on app launch
  Future<bool> restoreSession() async {
    try {
      final session = await AuthService.instance.restoreSession();
      if (session != null && session.isValid) {
        _currentUser = session.user;
        _currentSession = session;
        notifyListeners();
        return true;
      } else {
        _currentUser = null;
        _currentSession = null;
        notifyListeners();
        return false;
      }
    } catch (_) {
      _currentUser = null;
      _currentSession = null;
      notifyListeners();
      return false;
    }
  }

  /// Request password reset
  Future<bool> requestPasswordReset(String identifier) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await AuthService.instance.requestPasswordReset(identifier);
      _isLoading = false;
      _successMessage = 'Password reset link sent to your registered email.';
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _isLoading = false;
      _errorMessage = 'Unable to send password reset link. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    await AuthService.instance.logout();
    _currentUser = null;
    _currentSession = null;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  // Backwards compatibility methods for legacy tests or controllers
  void loginStudent({required String email, required String password}) {
    login(identifier: email, password: password);
  }

  void loginOrganizer({required String clubOrRole, required String password}) {
    login(identifier: clubOrRole, password: password);
  }
}
