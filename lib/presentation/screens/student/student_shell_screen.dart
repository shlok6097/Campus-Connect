import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../shared/navigation/app_bottom_nav_bar.dart';
import '../../shared/navigation/top_app_bar_widget.dart';
import '../../state/auth_controller.dart';
import '../clubs/club_discovery_screen.dart';
import '../events/events_list_screen.dart';
import '../games/games_hub_screen.dart';
import 'student_home_screen.dart';
import 'student_profile_screen.dart';

class StudentShellScreen extends StatefulWidget {
  final int initialTabIndex;

  const StudentShellScreen({super.key, this.initialTabIndex = 0});

  @override
  State<StudentShellScreen> createState() => _StudentShellScreenState();
}

class _StudentShellScreenState extends State<StudentShellScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
  }

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthController.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TopAppBarWidget(
        title: 'Campus Connect',
        avatarUrl: user.avatarUrl,
        onAvatarTap: () => _onTabChanged(4), // Navigate to profile
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          StudentHomeScreen(onNavigateTab: _onTabChanged),
          const EventsListScreen(),
          const ClubDiscoveryScreen(),
          const GamesHubScreen(),
          const StudentProfileScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
      ),
    );
  }
}
