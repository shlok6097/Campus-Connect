import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';
import '../models/user_model.dart';

class SrmDashboardStats {
  final int totalClubs;
  final int activeClubs;
  final int totalStudents;
  final int totalClubLeaders;

  const SrmDashboardStats({
    required this.totalClubs,
    required this.activeClubs,
    required this.totalStudents,
    required this.totalClubLeaders,
  });

  factory SrmDashboardStats.empty() {
    return const SrmDashboardStats(
      totalClubs: 0,
      activeClubs: 0,
      totalStudents: 0,
      totalClubLeaders: 0,
    );
  }
}

class SrmClubItem {
  final String id;
  final String name;
  final String description;
  final String category;
  final String logoUrl;
  final String status;
  final String? leaderName;
  final String? leaderEmail;
  final String? leaderUserId;
  final DateTime createdAt;

  const SrmClubItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.logoUrl,
    required this.status,
    this.leaderName,
    this.leaderEmail,
    this.leaderUserId,
    required this.createdAt,
  });

  factory SrmClubItem.fromJson(Map<String, dynamic> json) {
    String? leaderName;
    String? leaderEmail;
    String? leaderUserId;

    final membersList = json['club_members'] as List<dynamic>?;
    if (membersList != null && membersList.isNotEmpty) {
      for (final m in membersList) {
        if (m is Map<String, dynamic> && m['role'] == 'club_leader') {
          leaderUserId = m['user_id']?.toString();
          final profile = m['profiles'] as Map<String, dynamic>?;
          if (profile != null) {
            leaderName = (profile['full_name'] ?? profile['name'])?.toString();
            leaderEmail = profile['email']?.toString();
          }
          break;
        }
      }
    }

    final createdAtRaw = json['created_at'] ?? json['createdAt'];

    return SrmClubItem(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      category: (json['category'] ?? 'technical').toString(),
      logoUrl: (json['logo_url'] ?? json['logoUrl'] ?? '').toString(),
      status: (json['status'] ?? 'active').toString(),
      leaderName: leaderName ?? 'Unassigned',
      leaderEmail: leaderEmail,
      leaderUserId: leaderUserId,
      createdAt: createdAtRaw != null
          ? (DateTime.tryParse(createdAtRaw.toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }
}

class SrmRepository {
  static final SrmRepository instance = SrmRepository._internal();

  SrmRepository._internal();

  SupabaseClient get _client => SupabaseService.instance.client;

  /// Fetch SRM Dashboard counts
  Future<SrmDashboardStats> getDashboardStats() async {
    if (!SupabaseService.instance.isInitialized) {
      return SrmDashboardStats.empty();
    }

    try {
      final totalClubsRes = await _client
          .from('clubs')
          .count(CountOption.exact);

      final activeClubsRes = await _client
          .from('clubs')
          .count(CountOption.exact)
          .eq('status', 'active');

      final totalStudentsRes = await _client
          .from('profiles')
          .count(CountOption.exact)
          .eq('account_type', 'student');

      final totalLeadersRes = await _client
          .from('club_members')
          .count(CountOption.exact)
          .eq('role', 'club_leader');

      return SrmDashboardStats(
        totalClubs: totalClubsRes,
        activeClubs: activeClubsRes,
        totalStudents: totalStudentsRes,
        totalClubLeaders: totalLeadersRes,
      );
    } catch (_) {
      return SrmDashboardStats.empty();
    }
  }

  /// Fetch all clubs with their assigned leader details
  Future<List<SrmClubItem>> getClubs() async {
    if (!SupabaseService.instance.isInitialized) {
      return [];
    }

    try {
      final data = await _client
          .from('clubs')
          .select('*, club_members(user_id, role, profiles(full_name, email))')
          .order('created_at', ascending: false);

      final List<dynamic> list = data as List<dynamic>;
      return list.map((item) => SrmClubItem.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Fetch existing students for Club Leader assignment
  Future<List<UserModel>> getEligibleStudents() async {
    if (!SupabaseService.instance.isInitialized) {
      return [
        UserModel(
          id: '8472d1a4-62c3-4276-812c-4ca5bb597423',
          name: 'Rahul Kumar',
          email: 'rahul.kumar@uvce.edu',
          studentId: 'UVCE21CS045',
          branch: 'Computer Science',
          semester: 6,
        ),
        UserModel(
          id: '578beb87-7fd0-44db-b1a9-042deb891657',
          name: 'Ananya Sharma',
          email: 'ananya.sharma@uvce.edu',
          studentId: 'UVCE21CS002',
          branch: 'Computer Science',
          semester: 6,
        ),
      ];
    }

    try {
      final data = await _client
          .from('profiles')
          .select('*')
          .eq('account_type', 'student')
          .order('full_name', ascending: true);

      final List<dynamic> list = data as List<dynamic>;
      return list.map((item) => UserModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  /// SRM Create Club and assign initial Club Leader in Supabase
  Future<SrmClubItem> createClub({
    required String name,
    required String description,
    required String category,
    String? logoUrl,
    required String leaderUserId,
  }) async {
    if (!SupabaseService.instance.isInitialized) {
      return SrmClubItem(
        id: 'mock_club_${DateTime.now().millisecondsSinceEpoch}',
        name: name.trim(),
        description: description.trim(),
        category: category,
        logoUrl: logoUrl ?? '',
        status: 'active',
        leaderUserId: leaderUserId,
        createdAt: DateTime.now(),
      );
    }

    final client = _client;

    // 1. Insert into public.clubs
    final clubInsert = await client.from('clubs').insert({
      'name': name.trim(),
      'description': description.trim(),
      'category': category,
      'logo_url': logoUrl ?? '',
      'status': 'active',
      'created_by': client.auth.currentUser?.id,
    }).select().single();

    final clubId = (clubInsert['id'] ?? '').toString();

    // 2. Assign selected student as club_leader in public.club_members
    if (leaderUserId.isNotEmpty) {
      try {
        await client.from('club_members').upsert({
          'club_id': clubId,
          'user_id': leaderUserId,
          'role': 'club_leader',
        });
      } catch (_) {}

      // 3. Update leader's profile with club assignment
      try {
        await client.from('profiles').update({
          'club_id': clubId,
          'club_name': name.trim(),
          'role': 'club_leader',
          'account_type': 'club',
        }).eq('id', leaderUserId);
      } catch (_) {
        // Ignore if RLS restricts
      }
    }

    return SrmClubItem(
      id: clubId,
      name: name.trim(),
      description: description.trim(),
      category: category,
      logoUrl: logoUrl ?? '',
      status: 'active',
      leaderUserId: leaderUserId,
      createdAt: DateTime.now(),
    );
  }
}
