import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../shared/navigation/app_bottom_nav_bar.dart';
import '../../shared/navigation/top_app_bar_widget.dart';
import '../../state/auth_controller.dart';
import '../../state/club_controller.dart';
import '../clubs/club_members_screen.dart';
import '../events/events_list_screen.dart';
import '../student/student_shell_screen.dart';
import 'organizer_dashboard_screen.dart';
import 'registration_responses_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    final codingClub = ClubController.instance.allClubs.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TopAppBarWidget(
        title: 'Club Manager',
        showLeadingAvatar: true,
        actions: [
          TextButton.icon(
            onPressed: () {
              AuthController.instance.loginStudent(
                email: 'rahul.kumar@uvce.edu',
                password: 'password',
              );
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const StudentShellScreen()),
              );
            },
            icon: const Icon(Icons.swap_horiz, size: 16, color: AppColors.blue),
            label: const Text('Student View', style: TextStyle(color: AppColors.blue, fontSize: 12)),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          OrganizerDashboardScreen(onNavigateTab: _onTabChanged),
          const EventsListScreen(),
          const RegistrationResponsesScreen(),
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
