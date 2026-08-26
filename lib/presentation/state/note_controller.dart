import 'package:flutter/material.dart';
import '../../data/models/note_model.dart';
import '../../data/repositories/mock_repository.dart';

class NoteController extends ChangeNotifier {
  static final NoteController instance = NoteController._internal();
  NoteController._internal();

  final MockRepository _repo = MockRepository.instance;

  NoteSubject? _selectedSubject;
  String _searchQuery = '';

  NoteSubject? get selectedSubject => _selectedSubject;
  String get searchQuery => _searchQuery;

  List<NoteModel> get allNotes => _repo.notes;

  List<NoteModel> get filteredNotes {
    return _repo.notes.where((note) {
      final matchesSubj = _selectedSubject == null || note.subject == _selectedSubject;
      final matchesSearch = _searchQuery.isEmpty ||
          note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.topicsCovered.any((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()));
      return matchesSubj && matchesSearch;
    }).toList();
  }

  List<LeaderboardUser> get leaderboard => _repo.leaderboard;

  void setSubjectFilter(NoteSubject? subject) {
    _selectedSubject = subject;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void contributeNote(NoteModel note) {
    _repo.addNote(note);
    notifyListeners();
  }
}
