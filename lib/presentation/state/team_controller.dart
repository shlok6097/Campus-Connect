import 'package:flutter/material.dart';
import '../../data/models/team_model.dart';
import '../../data/repositories/mock_repository.dart';

class TeamController extends ChangeNotifier {
  static final TeamController instance = TeamController._internal();
  TeamController._internal();

  final MockRepository _repo = MockRepository.instance;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<TeamModel> get allTeams => _repo.teams;

  TeamModel get myTeam => _repo.teams.firstWhere(
        (t) => t.leaderId == _repo.currentUser.id || t.members.any((m) => m.id == _repo.currentUser.id),
        orElse: () => _repo.teams.first,
      );

  List<TeamModel> get discoverTeams => _repo.teams;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void updateProject(String teamId, ProjectModel updatedProject) {
    final index = _repo.teams.indexWhere((t) => t.id == teamId);
    if (index != -1) {
      final team = _repo.teams[index];
      _repo.teams[index] = TeamModel(
        id: team.id,
        name: team.name,
        eventName: team.eventName,
        eventId: team.eventId,
        leaderName: team.leaderName,
        leaderId: team.leaderId,
        members: team.members,
        project: updatedProject,
        sharedFiles: team.sharedFiles,
        recentActivity: [
          TeamActivityItem(
            id: 'act_${DateTime.now().millisecondsSinceEpoch}',
            userName: _repo.currentUser.name.split(' ').first,
            userAvatar: _repo.currentUser.avatarUrl,
            actionText: 'updated project details.',
            timeAgo: 'Just now',
          ),
          ...team.recentActivity,
        ],
      );
      notifyListeners();
    }
  }

  void addMember(String teamId, TeamMemberItem newMember) {
    final index = _repo.teams.indexWhere((t) => t.id == teamId);
    if (index != -1) {
      final team = _repo.teams[index];
      _repo.teams[index] = TeamModel(
        id: team.id,
        name: team.name,
        eventName: team.eventName,
        eventId: team.eventId,
        leaderName: team.leaderName,
        leaderId: team.leaderId,
        members: [...team.members, newMember],
        project: team.project,
        sharedFiles: team.sharedFiles,
        recentActivity: [
          TeamActivityItem(
            id: 'act_${DateTime.now().millisecondsSinceEpoch}',
            userName: _repo.currentUser.name.split(' ').first,
            userAvatar: _repo.currentUser.avatarUrl,
            actionText: 'invited ${newMember.name} to the team.',
            timeAgo: 'Just now',
          ),
          ...team.recentActivity,
        ],
      );
      notifyListeners();
    }
  }

  void addSharedFile(String teamId, SharedFileItem newFile) {
    final index = _repo.teams.indexWhere((t) => t.id == teamId);
    if (index != -1) {
      final team = _repo.teams[index];
      _repo.teams[index] = TeamModel(
        id: team.id,
        name: team.name,
        eventName: team.eventName,
        eventId: team.eventId,
        leaderName: team.leaderName,
        leaderId: team.leaderId,
        members: team.members,
        project: team.project,
        sharedFiles: [newFile, ...team.sharedFiles],
        recentActivity: [
          TeamActivityItem(
            id: 'act_${DateTime.now().millisecondsSinceEpoch}',
            userName: _repo.currentUser.name.split(' ').first,
            userAvatar: _repo.currentUser.avatarUrl,
            actionText: 'uploaded a file (${newFile.title}).',
            timeAgo: 'Just now',
          ),
          ...team.recentActivity,
        ],
      );
      notifyListeners();
    }
  }
}
