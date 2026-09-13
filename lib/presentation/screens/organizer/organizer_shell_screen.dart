import 'package:flutter/material.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../data/models/club_model.dart';
import '../../shared/navigation/app_bottom_nav_bar.dart';
import '../../shared/navigation/top_app_bar_widget.dart';
import '../../state/auth_controller.dart';
import '../../state/club_controller.dart';
import '../club/club_events_screen.dart';
import '../club/publish_hub_screen.dart';
import '../clubs/club_members_screen.dart';
import 'organizer_dashboard_screen.dart';

typedef ClubShellScreen = OrganizerShellScreen;

class OrganizerShellScreen extends StatefulWidget {
  final int initialTabIndex;

  const OrganizerShellScreen({super.key, this.initialTabIndex = 0});

  @override
  State<OrganizerShellScreen> createState() => _OrganizerShellScreenState();
}

class _OrganizerShellScreenState extends State<OrganizerShellScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
  }

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: AppDimens.borderLg),
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of the Club Dashboard?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await AuthController.instance.logout();
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.login,
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthController.instance.currentUser;
    final codingClub = ClubController.instance.allClubs
            .where((c) => c.id == user.clubId)
            .firstOrNull ??
        ClubController.instance.allClubs.firstOrNull ??
        ClubModel(
          id: user.clubId ?? 'club_default',
          name: user.clubName ?? 'My Club',
          tagline: 'Club Management Portal',
          description: 'Official Club Portal',
          category: ClubCategory.technical,
          logoUrl: '',
        );
    final title = user.clubName ?? 'Club Manager';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TopAppBarWidget(
        title: title,
        avatarUrl: user.avatarUrl,
        showLeadingAvatar: true,
        actions: [
          IconButton(
            tooltip: 'Log Out',
            icon: const Icon(Icons.logout, color: AppColors.red, size: 20),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          OrganizerDashboardScreen(onNavigateTab: _onTabChanged),
          const ClubEventsScreen(),
          const PublishHubScreen(),
          ClubMembersScreen(club: codingClub),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
        isOrganizer: true,
      ),
    );
  }
}
