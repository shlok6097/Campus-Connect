import 'package:flutter/foundation.dart';
import '../../core/services/publication_service.dart';
import '../../data/models/publication_model.dart';

class PublishController extends ChangeNotifier {
  static final PublishController instance = PublishController._internal();

  PublishController._internal();

  final PublicationService _service = PublicationService();

  List<PublicationModel> _publications = [];
  bool _isLoading = false;
  String _selectedFilter = 'ALL';
  String _searchQuery = '';

  List<PublicationModel> get allPublications => _publications;
  bool get isLoading => _isLoading;
  String get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;

  List<PublicationModel> get filteredPublications {
    var list = _publications;

    if (_selectedFilter != 'ALL') {
      list = list.where((p) => p.type.name.toUpperCase() == _selectedFilter.toUpperCase()).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      list = list.where((p) {
        return p.title.toLowerCase().contains(query) ||
            p.content.toLowerCase().contains(query) ||
            p.type.displayName.toLowerCase().contains(query);
      }).toList();
    }

    return list;
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadPublications({String? clubName, String? clubId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final items = await _service.fetchPublications(clubName: clubName, clubId: clubId);
      _publications = items;
    } catch (_) {
      // Retain in-memory items
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> publishContent(PublicationModel publication) async {
    _publications.insert(0, publication);
    notifyListeners();

    try {
      await _service.createPublication(publication);
    } catch (_) {}
    return true;
  }

  Future<bool> deletePublication(String id) async {
    _publications.removeWhere((p) => p.id == id);
    notifyListeners();

    try {
      await _service.deletePublication(id);
    } catch (_) {}
    return true;
  }

  void voteOnPoll(String publicationId, int optionIndex) {
    final index = _publications.indexWhere((p) => p.id == publicationId);
    if (index == -1) return;

    final pub = _publications[index];
    final meta = Map<String, dynamic>.from(pub.metadata);
    final options = List<Map<String, dynamic>>.from(meta['options'] ?? []);

    if (optionIndex >= 0 && optionIndex < options.length) {
      final currentVotes = (options[optionIndex]['votes'] as int? ?? 0) + 1;
      options[optionIndex]['votes'] = currentVotes;

      int total = 0;
      for (final opt in options) {
        total += (opt['votes'] as int? ?? 0);
      }
      meta['total_votes'] = total;
      for (final opt in options) {
        final v = opt['votes'] as int? ?? 0;
        opt['percent'] = total > 0 ? ((v / total) * 100).round() : 0;
      }
      meta['options'] = options;
      meta['has_voted'] = true;

      _publications[index] = pub.copyWith(metadata: meta);
      notifyListeners();
    }
  }
}
