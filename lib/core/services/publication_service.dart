import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/publication_model.dart';
import 'supabase_service.dart';

class PublicationService {
  SupabaseClient get _supabase => SupabaseService.instance.client;

  Future<List<PublicationModel>> fetchPublications({String? clubName, String? clubId}) async {
    try {
      var query = _supabase.from('club_publications').select().order('created_at', ascending: false);

      final response = await query;
      return (response as List).map((json) => PublicationModel.fromJson(json)).toList();
    } catch (_) {
      return _fallbackPublications(clubName: clubName);
    }
  }

  Future<PublicationModel?> createPublication(PublicationModel publication) async {
    try {
      final response = await _supabase
          .from('club_publications')
          .insert(publication.toJson())
          .select()
          .single();
      return PublicationModel.fromJson(response);
    } catch (_) {
      return publication;
    }
  }

  Future<bool> deletePublication(String id) async {
    try {
      await _supabase.from('club_publications').delete().eq('id', id);
      return true;
    } catch (_) {
      return true;
    }
  }

  Future<bool> toggleVote(String publicationId, int optionIndex) async {
    try {
      return true;
    } catch (_) {
      return true;
    }
  }

  List<PublicationModel> _fallbackPublications({String? clubName}) {
    final cName = clubName ?? 'Test club';
    return [
      PublicationModel(
        id: 'pub_quiz_1',
        clubName: cName,
        type: PublicationType.quiz,
        title: 'Cybersecurity Challenge: Network Security',
        content: 'Test your knowledge on cryptographic hashes, zero-day vulnerabilities, and packet sniffing.',
        metadata: {'participants': 85, 'questions_count': 10, 'difficulty': 'Intermediate'},
        authorName: 'shlok',
        likesCount: 24,
        viewsCount: 140,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      PublicationModel(
        id: 'pub_doc_1',
        clubName: cName,
        type: PublicationType.document,
        title: 'CodeSprint 2026 - Official Event Report',
        content: 'Complete summary, winning solutions breakdown, and judge feedback from CodeSprint 2026.',
        metadata: {'file_type': 'PDF', 'file_size': '4.2 MB', 'pages': 12},
        authorName: 'shlok',
        likesCount: 42,
        viewsCount: 310,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      PublicationModel(
        id: 'pub_poll_1',
        clubName: cName,
        type: PublicationType.poll,
        title: 'Next Hands-on Workshop Topic?',
        content: 'Vote on what technology stack we should cover in our next 2-day bootcamp.',
        metadata: {
          'total_votes': 245,
          'options': [
            {'label': 'React Native', 'votes': 110, 'percent': 45},
            {'label': 'Figma Advanced', 'votes': 74, 'percent': 30},
            {'label': 'AI & LLM Integration', 'votes': 61, 'percent': 25},
          ]
        },
        authorName: 'shlok',
        likesCount: 56,
        viewsCount: 520,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      PublicationModel(
        id: 'pub_fact_1',
        clubName: cName,
        type: PublicationType.fact,
        title: 'Did you know? (IPv4 vs IPv6)',
        content: 'IPv4 addresses are 32-bit numbers, allowing for about 4.3 billion unique addresses. IPv6 addresses are 128-bit numbers, allowing for 340 undecillion addresses!',
        metadata: {'category': 'Computer Networks', 'verified': true},
        authorName: 'shlok',
        likesCount: 89,
        viewsCount: 670,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      PublicationModel(
        id: 'pub_news_1',
        clubName: cName,
        type: PublicationType.news,
        title: 'Campus Innovation Grant Awarded',
        content: 'Our club has secured a ₹50,000 innovation grant from the University Tech Fund for upcoming open-source robotics research.',
        metadata: {'badge': 'Grant Alert', 'grant_amount': '₹50,000'},
        authorName: 'shlok',
        likesCount: 105,
        viewsCount: 920,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }
}
