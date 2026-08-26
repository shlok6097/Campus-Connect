import 'package:flutter/material.dart';
import '../../data/models/club_model.dart';
import '../../data/repositories/mock_repository.dart';

class ClubController extends ChangeNotifier {
  static final ClubController instance = ClubController._internal();
  ClubController._internal();

  final MockRepository _repo = MockRepository.instance;

  ClubCategory? _selectedCategory;
  String _searchQuery = '';

  ClubCategory? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<ClubModel> get allClubs => _repo.clubs;

  List<ClubModel> get myClubs => _repo.clubs.where((c) => c.isUserJoined).toList();

  List<ClubModel> get filteredClubs {
    return _repo.clubs.where((club) {
      final matchesCat = _selectedCategory == null || club.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          club.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          club.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();
  }

  void setCategoryFilter(ClubCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void joinClub(String clubId) {
    _repo.joinClub(clubId);
    notifyListeners();
  }

  void addMemberToClub(String clubId, ClubMemberItem member) {
    final index = _repo.clubs.indexWhere((c) => c.id == clubId);
    if (index != -1) {
      final club = _repo.clubs[index];
      _repo.clubs[index] = club.copyWith(
        members: [...club.members, member],
        memberCount: club.memberCount + 1,
      );
      notifyListeners();
    }
  }

  void removeMemberFromClub(String clubId, String memberId) {
    final index = _repo.clubs.indexWhere((c) => c.id == clubId);
    if (index != -1) {
      final club = _repo.clubs[index];
      _repo.clubs[index] = club.copyWith(
        members: club.members.where((m) => m.id != memberId).toList(),
        memberCount: (club.memberCount - 1).clamp(0, 9999),
      );
      notifyListeners();
    }
  }

  void updateMemberRole(String clubId, String memberId, String newRole, bool isManager) {
    final index = _repo.clubs.indexWhere((c) => c.id == clubId);
    if (index != -1) {
      final club = _repo.clubs[index];
      final memberIndex = club.members.indexWhere((m) => m.id == memberId);
      if (memberIndex != -1) {
        final currentMember = club.members[memberIndex];
        final updatedList = List<ClubMemberItem>.from(club.members);
        updatedList[memberIndex] = ClubMemberItem(
          id: currentMember.id,
          name: currentMember.name,
          role: newRole,
          branch: currentMember.branch,
          semester: currentMember.semester,
          avatarUrl: currentMember.avatarUrl,
          joinedDate: currentMember.joinedDate,
          isManager: isManager,
        );
        _repo.clubs[index] = club.copyWith(members: updatedList);
        notifyListeners();
      }
    }
  }
}
