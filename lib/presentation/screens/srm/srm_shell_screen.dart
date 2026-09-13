import 'package:flutter/material.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../shared/navigation/top_app_bar_widget.dart';
import '../../state/auth_controller.dart';
import '../clubs/club_discovery_screen.dart';
import '../events/events_list_screen.dart';
import 'srm_dashboard_screen.dart';

class SrmShellScreen extends StatefulWidget {
  final int initialTabIndex;

  const SrmShellScreen({super.key, this.initialTabIndex = 0});

  @override
  State<SrmShellScreen> createState() => _SrmShellScreenState();
}

class _SrmShellScreenState extends State<SrmShellScreen> {
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
        content: const Text('Are you sure you want to log out of the SRM Portal?'),
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TopAppBarWidget(
        title: 'SRM Portal',
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
          SrmDashboardScreen(onNavigateTab: _onTabChanged),
          const ClubDiscoveryScreen(),
          const EventsListScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.outlineVariant, width: 1)),
          boxShadow: AppDimens.cardShadow,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                _buildNavItem(0, Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
                _buildNavItem(1, Icons.groups_outlined, Icons.groups, 'Clubs'),
                _buildNavItem(2, Icons.event_note_outlined, Icons.event_note, 'Campus Events'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onTabChanged(index),
        borderRadius: AppDimens.borderPill,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.greenLight : Colors.transparent,
            borderRadius: AppDimens.borderPill,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? AppColors.green : AppColors.textSecondary,
                size: 22,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? AppColors.green : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
