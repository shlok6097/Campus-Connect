import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';
import '../../data/models/club_model.dart';
import '../../data/repositories/mock_repository.dart';
import 'auth_controller.dart';

class ClubController extends ChangeNotifier {
  static final ClubController instance = ClubController._internal();
  ClubController._internal() {
    loadClubs();
  }

  List<ClubModel> _clubs = [];
  bool _isLoading = false;
  String? _errorMessage;

  ClubCategory? _selectedCategory;
  String _searchQuery = '';

  List<ClubModel> get _sourceClubs => _clubs.isNotEmpty
      ? _clubs
      : (!SupabaseService.instance.isInitialized ? MockRepository.instance.clubs : []);

  List<ClubModel> get allClubs => _sourceClubs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ClubCategory? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<ClubModel> get myClubs => _sourceClubs.where((c) => c.isUserJoined).toList();

  List<ClubModel> get filteredClubs {
    return _sourceClubs.where((club) {
      final matchesCat = _selectedCategory == null || club.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          club.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          club.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();
  }

  Future<void> loadClubs() async {
    if (!SupabaseService.instance.isInitialized) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final client = SupabaseService.instance.client;
      final currentUserId = AuthController.instance.currentUser.id;

      dynamic data;
      try {
        data = await client
            .from('clubs')
            .select('*, club_members(user_id, role, privileges, profiles(full_name, email, usn, branch, semester, avatar_url))')
            .order('created_at', ascending: false);
      } catch (_) {
        // Fallback to simpler query if nested relations fail
        data = await client
            .from('clubs')
            .select('*')
            .order('created_at', ascending: false);
      }

      final List<dynamic> list = (data as List<dynamic>?) ?? [];
      _clubs = list.map((item) {
        return ClubModel.fromJson(
          item as Map<String, dynamic>,
          currentUserId: currentUserId,
        );
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load clubs: $e';
      notifyListeners();
    }
  }

  void setCategoryFilter(ClubCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> joinClub(String clubId) async {
    final currentUserId = AuthController.instance.currentUser.id;

    final index = _clubs.indexWhere((c) => c.id == clubId);
    if (index != -1) {
      final club = _clubs[index];
      _clubs[index] = club.copyWith(
        isUserJoined: true,
        userRole: 'Member',
        memberCount: club.memberCount + 1,
      );
      notifyListeners();
    } else if (!SupabaseService.instance.isInitialized) {
      MockRepository.instance.joinClub(clubId);
      notifyListeners();
    }

    if (SupabaseService.instance.isInitialized) {
      try {
        final client = SupabaseService.instance.client;
        await client.from('club_members').upsert({
          'club_id': clubId,
          'user_id': currentUserId,
          'role': 'member',
          'privileges': ['view_events'],
        });
      } catch (_) {}
    }
  }

  Future<void> addMemberToClub(String clubId, ClubMemberItem member) async {
    if (_clubs.isEmpty && MockRepository.instance.clubs.isNotEmpty) {
      _clubs = List<ClubModel>.from(MockRepository.instance.clubs);
    }
    final index = _clubs.indexWhere((c) => c.id == clubId);
    if (index != -1) {
      final club = _clubs[index];
      _clubs[index] = club.copyWith(
        members: [...club.members, member],
        memberCount: club.memberCount + 1,
      );
      notifyListeners();
    }

    if (SupabaseService.instance.isInitialized) {
      try {
        final client = SupabaseService.instance.client;
        await client.from('club_members').upsert({
          'club_id': clubId,
          'user_id': member.id,
          'role': member.role,
          'privileges': member.privileges,
        });
      } catch (_) {}
    }
  }

  Future<void> removeMemberFromClub(String clubId, String memberId) async {
    if (_clubs.isEmpty && MockRepository.instance.clubs.isNotEmpty) {
      _clubs = List<ClubModel>.from(MockRepository.instance.clubs);
    }
    final index = _clubs.indexWhere((c) => c.id == clubId);
    if (index != -1) {
      final club = _clubs[index];
      _clubs[index] = club.copyWith(
        members: club.members.where((m) => m.id != memberId).toList(),
        memberCount: (club.memberCount - 1).clamp(0, 9999),
      );
      notifyListeners();
    }

    if (SupabaseService.instance.isInitialized) {
      try {
        final client = SupabaseService.instance.client;
        await client
            .from('club_members')
            .delete()
            .eq('club_id', clubId)
            .eq('user_id', memberId);
      } catch (_) {}
    }
  }

  Future<void> updateMemberRoleAndPrivileges(
    String clubId,
    String memberId,
    String newRole,
    bool isManager,
    List<String> newPrivileges,
  ) async {
    if (_clubs.isEmpty && MockRepository.instance.clubs.isNotEmpty) {
      _clubs = List<ClubModel>.from(MockRepository.instance.clubs);
    }
    final index = _clubs.indexWhere((c) => c.id == clubId);
    if (index != -1) {
      final club = _clubs[index];
      final memberIndex = club.members.indexWhere((m) => m.id == memberId);
      if (memberIndex != -1) {
        final currentMember = club.members[memberIndex];
        final updatedList = List<ClubMemberItem>.from(club.members);
        updatedList[memberIndex] = currentMember.copyWith(
          role: newRole,
          isManager: isManager,
          privileges: newPrivileges,
        );
        _clubs[index] = club.copyWith(members: updatedList);
        notifyListeners();
      }
    }

    if (SupabaseService.instance.isInitialized) {
      try {
        final client = SupabaseService.instance.client;
        await client.from('club_members').update({
          'role': newRole,
          'privileges': newPrivileges,
        }).eq('club_id', clubId).eq('user_id', memberId);
      } catch (_) {}
    }
  }

  Future<List<Map<String, dynamic>>> fetchAvailableStudents(String clubId) async {
    if (!SupabaseService.instance.isInitialized) return [];
    try {
      final client = SupabaseService.instance.client;
      final response = await client.from('profiles').select('id, full_name, email, usn, branch, semester, avatar_url');
      final currentClub = _clubs.firstWhere((c) => c.id == clubId, orElse: () => _clubs.first);
      final memberUserIds = currentClub.members.map((m) => m.id).toSet();

      final list = (response as List).cast<Map<String, dynamic>>();
      return list.where((p) => !memberUserIds.contains(p['id'])).toList();
    } catch (_) {
      return [];
    }
  }
}
