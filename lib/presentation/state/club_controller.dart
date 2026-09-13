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
      final authUser = client.auth.currentUser;
      final currentUserId = (authUser?.id != null && authUser!.id.isNotEmpty)
          ? authUser.id
          : AuthController.instance.currentUser.id;

      dynamic clubsData;
      List<dynamic> allMembers = [];

      try {
        clubsData = await client
            .from('clubs')
            .select('*, club_members(user_id, role, privileges, profiles(full_name, email, usn, branch, semester, avatar_url))')
            .order('created_at', ascending: false);
      } catch (nestedErr) {
        debugPrint('[LOAD_CLUBS_DEBUG] Nested join failed ($nestedErr), executing robust separate fetch...');
        clubsData = await client
            .from('clubs')
            .select('*')
            .order('created_at', ascending: false);

        try {
          allMembers = await client
              .from('club_members')
              .select('*, profiles(full_name, email, usn, branch, semester, avatar_url)');
        } catch (_) {
          try {
            allMembers = await client.from('club_members').select('*');
          } catch (_) {}
        }
      }

      final List<dynamic> list = (clubsData as List<dynamic>?) ?? [];

      // If separate fetch was executed, merge club_members into each club map
      if (allMembers.isNotEmpty) {
        final Map<String, List<dynamic>> membersByClub = {};
        for (final m in allMembers) {
          final cId = (m['club_id'] ?? '').toString();
          membersByClub.putIfAbsent(cId, () => []).add(m);
        }
        for (final clubJson in list) {
          if (clubJson is Map<String, dynamic>) {
            final cId = (clubJson['id'] ?? '').toString();
            clubJson['club_members'] = membersByClub[cId] ?? [];
          }
        }
      }

      _clubs = list.map((item) {
        return ClubModel.fromJson(
          item as Map<String, dynamic>,
          currentUserId: currentUserId,
        );
      }).toList();

      debugPrint('[LOAD_CLUBS_DEBUG] Loaded ${_clubs.length} clubs:');
      for (final c in _clubs) {
        debugPrint('  • ${c.name}: ${c.memberCount} followers (isJoined: ${c.isUserJoined}, role: ${c.userRole})');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load clubs: $e';
      debugPrint('[LOAD_CLUBS_DEBUG] Failed to load clubs: $e');
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

  Future<bool> joinClub(String clubId) async {
    final authUser = SupabaseService.instance.isInitialized
        ? SupabaseService.instance.client.auth.currentUser
        : null;
    final currentUserId = (authUser?.id != null && authUser!.id.isNotEmpty)
        ? authUser.id
        : AuthController.instance.currentUser.id;

    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[FOLLOW_DEBUG] ▶ joinClub() CALLED');
    debugPrint('[FOLLOW_DEBUG]   Club ID: $clubId');
    debugPrint('[FOLLOW_DEBUG]   Current User ID: $currentUserId');
    debugPrint('[FOLLOW_DEBUG]   Auth User Email: ${authUser?.email ?? AuthController.instance.currentUser.email}');
    debugPrint('[FOLLOW_DEBUG]   Supabase Initialized: ${SupabaseService.instance.isInitialized}');
    debugPrint('════════════════════════════════════════════════════════════════');

    final index = _clubs.indexWhere((c) => c.id == clubId);
    if (index != -1) {
      final club = _clubs[index];
      _clubs[index] = club.copyWith(
        isUserJoined: true,
        userRole: 'Member',
        memberCount: club.memberCount + 1,
      );
      notifyListeners();
      debugPrint('[FOLLOW_DEBUG]   ✓ Optimistic local state updated (+1). New count: ${_clubs[index].memberCount}');
    } else if (!SupabaseService.instance.isInitialized) {
      MockRepository.instance.joinClub(clubId);
      notifyListeners();
      debugPrint('[FOLLOW_DEBUG]   ✓ MockRepository state updated.');
    }

    if (SupabaseService.instance.isInitialized && currentUserId.isNotEmpty) {
      try {
        final client = SupabaseService.instance.client;
        final payload = {
          'club_id': clubId,
          'user_id': currentUserId,
          'role': 'member',
          'privileges': ['view_events'],
        };
        debugPrint('[FOLLOW_DEBUG]   → Writing to Supabase public.club_members: $payload');

        final response = await client.from('club_members').upsert(
          payload,
          onConflict: 'club_id,user_id',
        ).select();

        debugPrint('[FOLLOW_DEBUG]   ✓ Supabase response: $response');
        debugPrint('[FOLLOW_DEBUG]   → Reloading clubs from Supabase to sync live follower counts...');

        await loadClubs();

        final updatedClub = _clubs.firstWhere((c) => c.id == clubId, orElse: () => _clubs.first);
        debugPrint('[FOLLOW_DEBUG]   ✓ Database sync complete! Active followers in DB: ${updatedClub.memberCount}');
        debugPrint('════════════════════════════════════════════════════════════════');
        return true;
      } catch (e, stack) {
        debugPrint('[FOLLOW_DEBUG]   ✗ ERROR writing follow/membership to DB: $e');
        debugPrint('[FOLLOW_DEBUG]   Stack: $stack');
        debugPrint('════════════════════════════════════════════════════════════════');
        return false;
      }
    } else {
      debugPrint('[FOLLOW_DEBUG]   ⚠ Skipped Supabase write: Supabase init=${SupabaseService.instance.isInitialized}, userIdEmpty=${currentUserId.isEmpty}');
      return true;
    }
  }

  Future<bool> leaveClub(String clubId) async {
    final authUser = SupabaseService.instance.isInitialized
        ? SupabaseService.instance.client.auth.currentUser
        : null;
    final currentUserId = (authUser?.id != null && authUser!.id.isNotEmpty)
        ? authUser.id
        : AuthController.instance.currentUser.id;

    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('[FOLLOW_DEBUG] ▶ leaveClub() CALLED');
    debugPrint('[FOLLOW_DEBUG]   Club ID: $clubId');
    debugPrint('[FOLLOW_DEBUG]   Current User ID: $currentUserId');
    debugPrint('════════════════════════════════════════════════════════════════');

    final index = _clubs.indexWhere((c) => c.id == clubId);
    if (index != -1) {
      final club = _clubs[index];
      _clubs[index] = club.copyWith(
        isUserJoined: false,
        userRole: 'None',
        memberCount: (club.memberCount > 0) ? club.memberCount - 1 : 0,
        members: club.members.where((m) => m.id != currentUserId).toList(),
      );
      notifyListeners();
      debugPrint('[FOLLOW_DEBUG]   ✓ Optimistic local state updated (-1). New count: ${_clubs[index].memberCount}');
    }

    if (SupabaseService.instance.isInitialized && currentUserId.isNotEmpty) {
      try {
        final client = SupabaseService.instance.client;
        debugPrint('[FOLLOW_DEBUG]   → Deleting row from public.club_members (club_id=$clubId, user_id=$currentUserId)...');

        await client
            .from('club_members')
            .delete()
            .eq('club_id', clubId)
            .eq('user_id', currentUserId);

        debugPrint('[FOLLOW_DEBUG]   ✓ Row deleted from Supabase. Reloading clubs...');

        await loadClubs();

        final updatedClub = _clubs.firstWhere((c) => c.id == clubId, orElse: () => _clubs.first);
        debugPrint('[FOLLOW_DEBUG]   ✓ Unfollow sync complete! Active followers in DB: ${updatedClub.memberCount}');
        debugPrint('════════════════════════════════════════════════════════════════');
        return true;
      } catch (e, stack) {
        debugPrint('[FOLLOW_DEBUG]   ✗ ERROR deleting from DB: $e');
        debugPrint('[FOLLOW_DEBUG]   Stack: $stack');
        debugPrint('════════════════════════════════════════════════════════════════');
        return false;
      }
    }
    return true;
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
        }, onConflict: 'club_id,user_id');

        await loadClubs();
      } catch (e) {
        debugPrint('Error adding member to DB: $e');
      }
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

        await loadClubs();
      } catch (e) {
        debugPrint('Error removing member from DB: $e');
      }
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
