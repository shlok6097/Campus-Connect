import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/srm_repository.dart';

class SrmController extends ChangeNotifier {
  static final SrmController instance = SrmController._internal();

  SrmController._internal();

  SrmDashboardStats _stats = SrmDashboardStats.empty();
  List<SrmClubItem> _clubs = [];
  List<UserModel> _availableStudents = [];
  bool _isLoading = false;
  bool _isCreating = false;
  String? _errorMessage;
  String? _successMessage;

  SrmDashboardStats get stats => _stats;
  List<SrmClubItem> get clubs => _clubs;
  List<UserModel> get availableStudents => _availableStudents;
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  /// Load all SRM dashboard statistics, managed clubs, and eligible students
  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        SrmRepository.instance.getDashboardStats(),
        SrmRepository.instance.getClubs(),
        SrmRepository.instance.getEligibleStudents(),
      ]);

      _stats = results[0] as SrmDashboardStats;
      _clubs = results[1] as List<SrmClubItem>;
      _availableStudents = results[2] as List<UserModel>;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load SRM Dashboard data: $e';
      notifyListeners();
    }
  }

  /// Create club and assign initial club leader
  Future<bool> createClub({
    required String name,
    required String description,
    required String category,
    String? logoUrl,
    required String leaderUserId,
  }) async {
    _isCreating = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await SrmRepository.instance.createClub(
        name: name,
        description: description,
        category: category,
        logoUrl: logoUrl,
        leaderUserId: leaderUserId,
      );

      _successMessage = 'Club "$name" provisioned successfully!';
      _isCreating = false;
      
      // Reload updated data
      await loadDashboard();
      return true;
    } catch (e) {
      _isCreating = false;
      _errorMessage = 'Failed to create club: $e';
      notifyListeners();
      return false;
    }
  }
}
