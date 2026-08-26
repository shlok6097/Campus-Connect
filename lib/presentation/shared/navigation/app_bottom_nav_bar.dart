import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isOrganizer;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isOrganizer = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isOrganizer) {
      return _buildOrganizerNavBar();
    }
    return _buildStudentNavBar();
  }

  Widget _buildStudentNavBar() {
    final items = [
      const _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
      const _NavItem(icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month, label: 'Events'),
      const _NavItem(icon: Icons.groups_outlined, activeIcon: Icons.groups, label: 'Clubs'),
      const _NavItem(icon: Icons.sports_esports_outlined, activeIcon: Icons.sports_esports, label: 'Games'),
      const _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.outlineVariant, width: 1)),
        boxShadow: AppDimens.cardShadow,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = currentIndex == index;

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  borderRadius: AppDimens.borderPill,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.blueContainer : Colors.transparent,
                      borderRadius: AppDimens.borderPill,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: isSelected ? AppColors.white : AppColors.textSecondary,
                          size: 22,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: isSelected ? AppColors.white : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildOrganizerNavBar() {
    final items = [
      const _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Dashboard'),
      const _NavItem(icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_today, label: 'Events'),
      const _NavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: 'Responses'),
      const _NavItem(icon: Icons.group_outlined, activeIcon: Icons.group, label: 'Members'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.outlineVariant, width: 1)),
        boxShadow: AppDimens.cardShadow,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = currentIndex == index;

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  borderRadius: AppDimens.borderPill,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.blueContainer : Colors.transparent,
                      borderRadius: AppDimens.borderPill,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: isSelected ? AppColors.white : AppColors.textSecondary,
                          size: 22,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: isSelected ? AppColors.white : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
