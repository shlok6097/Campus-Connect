import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/club_model.dart';
import '../../shared/buttons/primary_button.dart';
import '../../shared/cards/bento_card.dart';
import '../../shared/chips/app_chips.dart';
import '../../shared/feedback/custom_bottom_sheet.dart';
import '../../shared/headers/section_header.dart';
import '../../state/auth_controller.dart';
import '../../state/club_controller.dart';
import 'club_details_screen.dart';

class MyClubsScreen extends StatelessWidget {
  const MyClubsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ClubController.instance,
      builder: (context, _) {
        final myClubs = ClubController.instance.myClubs;
        final allClubs = ClubController.instance.allClubs;
        final unjoinedClubs = allClubs.where((c) => !c.isUserJoined).toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            title: Text(
              'My Clubs',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.blue,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.marginMobile),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(title: 'Active Memberships', icon: Icons.verified_user_outlined),
                  const SizedBox(height: AppDimens.md),
                  if (myClubs.isEmpty)
                    BentoCard(
                      padding: const EdgeInsets.all(AppDimens.lg),
                      child: Center(
                        child: Text(
                          'You have not joined any clubs yet.',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  else
                    ...myClubs.map((club) => _buildMyClubCard(context, club)),
                  const SizedBox(height: AppDimens.xl),

                  // Discover Section to Trigger Join Flow
                  SectionHeader(title: 'Discover & Join', icon: Icons.explore_outlined),
                  const SizedBox(height: AppDimens.md),
                  ...unjoinedClubs.map((club) => _buildJoinTriggerCard(context, club)),
                  const SizedBox(height: AppDimens.xxl),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMyClubCard(BuildContext context, ClubModel club) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.md),
      child: BentoCard(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ClubDetailsScreen(club: club)),
          );
        },
        padding: const EdgeInsets.all(AppDimens.md),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: AppDimens.borderMd,
                color: AppColors.blueLight,
              ),
              alignment: Alignment.center,
              clipBehavior: Clip.antiAlias,
              child: club.logoUrl.isNotEmpty
                  ? Image.network(
                      club.logoUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Text(
                        club.name.isNotEmpty ? club.name[0].toUpperCase() : 'C',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blue,
                        ),
                      ),
                    )
                  : Text(
                      club.name.isNotEmpty ? club.name[0].toUpperCase() : 'C',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blue,
                      ),
                    ),
            ),
            const SizedBox(width: AppDimens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(club.name, style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 14, color: AppColors.blue),
                      const SizedBox(width: 4),
                      Text(club.userRole, style: AppTextStyles.bodySmall.copyWith(color: AppColors.blue, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      StatusBadge.info(club.category.name.toUpperCase()),
                      const SizedBox(width: 8),
                      Text(
                        '• ${club.memberCount} Following',
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.outline),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinTriggerCard(BuildContext context, ClubModel club) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.md),
      child: BentoCard(
        onTap: () => _showJoinConfirmationSheet(context, club),
        padding: const EdgeInsets.all(AppDimens.md),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: AppDimens.borderMd,
                color: AppColors.blueLight,
              ),
              alignment: Alignment.center,
              clipBehavior: Clip.antiAlias,
              child: club.logoUrl.isNotEmpty
                  ? Image.network(
                      club.logoUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Text(
                        club.name.isNotEmpty ? club.name[0].toUpperCase() : 'C',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blue,
                        ),
                      ),
                    )
                  : Text(
                      club.name.isNotEmpty ? club.name[0].toUpperCase() : 'C',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blue,
                      ),
                    ),
            ),
            const SizedBox(width: AppDimens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(club.name, style: AppTextStyles.titleLarge.copyWith(fontSize: 16)),
                  Text(club.tagline, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.blue),
          ],
        ),
      ),
    );
  }

  void _showJoinConfirmationSheet(BuildContext context, ClubModel club) {
    final user = AuthController.instance.currentUser;

    CustomBottomSheet.show(
      context: context,
      title: 'Join ${club.name}?',
      subtitle: 'Become a member and participate in club activities, projects, and events.',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BentoCard(
            backgroundColor: AppColors.surfaceContainerLow,
            padding: const EdgeInsets.all(AppDimens.md),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.blueLight,
                  ),
                  alignment: Alignment.center,
                  clipBehavior: Clip.antiAlias,
                  child: user.avatarUrl.isNotEmpty
                      ? Image.network(
                          user.avatarUrl,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.blue,
                            ),
                          ),
                        )
                      : Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blue,
                          ),
                        ),
                ),
                const SizedBox(width: AppDimens.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name, style: AppTextStyles.titleLarge.copyWith(fontSize: 15)),
                    Text(
                      user.endingYear > 0
                          ? '${user.branch} • Batch of ${user.endingYear}'
                          : '${user.branch} • Sem ${user.semester}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.lg),
          PrimaryButton(
            label: 'Confirm Join',
            backgroundColor: AppColors.green,
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await ClubController.instance.joinClub(club.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Successfully joined ${club.name}! 🎉'
                          : 'Failed to record follow in DB. Check debug console.',
                    ),
                    backgroundColor: success ? AppColors.green : AppColors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
