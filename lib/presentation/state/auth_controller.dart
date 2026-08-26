import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/mock_repository.dart';

class AuthController extends ChangeNotifier {
  static final AuthController instance = AuthController._internal();
  AuthController._internal() {
    _currentUser = MockRepository.instance.currentUser;
  }

  late UserModel _currentUser;
  UserRole _currentRole = UserRole.student;
  String _currentClubOrRole = 'Coding Club Manager';
  bool _isLoggedIn = true;

  UserModel get currentUser => _currentUser;
  UserRole get currentRole => _currentRole;
  String get currentClubOrRole => _currentClubOrRole;
  bool get isLoggedIn => _isLoggedIn;
  bool get isStudent => _currentRole == UserRole.student;
  bool get isOrganizer => _currentRole == UserRole.organizer;

  void loginStudent({required String email, required String password}) {
    _currentRole = UserRole.student;
    _isLoggedIn = true;
    notifyListeners();
  }

  void loginOrganizer({required String clubOrRole, required String password}) {
    _currentRole = UserRole.organizer;
    _currentClubOrRole = clubOrRole;
    _isLoggedIn = true;
    notifyListeners();
  }

  void registerStudent({
    required String name,
    required String studentId,
    required String email,
    required String phone,
    required String branch,
    required int semester,
  }) {
    _currentUser = _currentUser.copyWith(
      name: name,
      studentId: studentId,
      email: email,
      phone: phone,
      branch: branch,
      semester: semester,
    );
    _currentRole = UserRole.student;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}
