import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/club_model.dart';
import '../../shared/buttons/primary_button.dart';
import '../../shared/cards/bento_card.dart';
import '../../shared/chips/app_chips.dart';
import '../../shared/headers/section_header.dart';
import '../../state/club_controller.dart';
import 'club_members_screen.dart';

class ClubDetailsScreen extends StatelessWidget {
  final ClubModel club;

  const ClubDetailsScreen({super.key, required this.club});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ClubController.instance,
      builder: (context, _) {
        final currentClub = ClubController.instance.allClubs.firstWhere(
          (c) => c.id == club.id,
          orElse: () => club,
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            title: Text(
              currentClub.name,
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.blue,
              ),
            ),
            actions: [
              if (currentClub.members.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.people_outline, color: AppColors.blue),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ClubMembersScreen(club: currentClub)),
                    );
                  },
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.marginMobile,
              vertical: AppDimens.lg,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Hero Section Bento Card
                  _buildHeroSection(context, currentClub),
                  const SizedBox(height: AppDimens.xl),

                  // 2. Responsive 2-Column Details
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth > 700;
                      if (isDesktop) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                children: [
                                  _buildAboutSection(currentClub),
                                  const SizedBox(height: AppDimens.lg),
                                  if (currentClub.buildingProjectTitle.isNotEmpty)
                                    _buildBuildingProjectSection(currentClub),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppDimens.md),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  _buildUpcomingActivities(currentClub),
                                  const SizedBox(height: AppDimens.lg),
                                  _buildAchievementsSection(currentClub),
                                ],
                              ),
                            ),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          _buildAboutSection(currentClub),
                          const SizedBox(height: AppDimens.lg),
                          if (currentClub.buildingProjectTitle.isNotEmpty) ...[
                            _buildBuildingProjectSection(currentClub),
                            const SizedBox(height: AppDimens.lg),
                          ],
                          _buildUpcomingActivities(currentClub),
                          const SizedBox(height: AppDimens.lg),
                          _buildAchievementsSection(currentClub),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppDimens.xxl),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroSection(BuildContext context, ClubModel club) {
    return BentoCard(
      padding: const EdgeInsets.all(AppDimens.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: AppDimens.borderLg,
              color: AppColors.blueLight,
            ),
            alignment: Alignment.center,
            clipBehavior: Clip.antiAlias,
            child: club.logoUrl.isNotEmpty
                ? Image.network(
                    club.logoUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Text(
                      club.name.isNotEmpty ? club.name[0].toUpperCase() : 'C',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blue,
                      ),
                    ),
                  )
                : Text(
                    club.name.isNotEmpty ? club.name[0].toUpperCase() : 'C',
                    style: const TextStyle(
                      fontSize: 32,
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
                Text(
                  club.name,
                  style: AppTextStyles.displayLargeMobile.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusBadge.info(club.category.name.toUpperCase()),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.people, size: 14, color: AppColors.blue),
                        const SizedBox(width: 4),
                        Text(
                          '${club.memberCount} Students Following',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.md),
                Row(
                  children: [
                    PrimaryButton(
                      label: club.isUserJoined ? 'Following (${club.userRole})' : 'Follow & Join Club',
                      icon: club.isUserJoined ? Icons.check_circle : Icons.group_add,
                      isFullWidth: false,
                      backgroundColor: club.isUserJoined ? AppColors.blue : AppColors.green,
                      onPressed: club.isUserJoined
                          ? () {
                              _showLeaveConfirmation(context, club);
                            }
                          : () async {
                              final success = await ClubController.instance.joinClub(club.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? 'Now following ${club.name}! 🎉'
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLeaveConfirmation(BuildContext context, ClubModel club) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Unfollow ${club.name}?'),
        content: const Text('You will stop receiving updates and membership notifications for this club.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await ClubController.instance.leaveClub(club.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Unfollowed ${club.name}'
                          : 'Failed to unfollow in DB. Check debug console.',
                    ),
                    backgroundColor: success ? AppColors.textPrimary : AppColors.red,
                  ),
                );
              }
            },
            child: const Text('Unfollow', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(ClubModel club) {
    return BentoCard(
      padding: const EdgeInsets.all(AppDimens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'About Us', icon: Icons.info_outline),
          const SizedBox(height: AppDimens.sm),
          Text(
            club.description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuildingProjectSection(ClubModel club) {
    return BentoCard(
      padding: const EdgeInsets.all(AppDimens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: "What We're Building", icon: Icons.construction_outlined),
          const SizedBox(height: AppDimens.md),
          Text(
            club.buildingProjectTitle,
            style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700, color: AppColors.blue),
          ),
          const SizedBox(height: 4),
          Text(
            club.buildingProjectDesc,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimens.md),
          Wrap(
            spacing: 6,
            children: club.buildingProjectTech.map((t) => SkillChip(label: t)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingActivities(ClubModel club) {
    return BentoCard(
      padding: const EdgeInsets.all(AppDimens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Upcoming Activities', icon: Icons.event_note_outlined),
          const SizedBox(height: AppDimens.md),
          if (club.upcomingActivities.isEmpty)
            Text('No scheduled activities at this time.', style: AppTextStyles.bodySmall)
          else
            ...club.upcomingActivities.map((act) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.md),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.blueLight,
                        borderRadius: AppDimens.borderMd,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(act.month, style: AppTextStyles.labelMedium.copyWith(fontSize: 10, color: AppColors.blue)),
                          Text(act.day, style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700, color: AppColors.blue)),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDimens.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(act.title, style: AppTextStyles.titleLarge.copyWith(fontSize: 15)),
                          Text(act.description, style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(ClubModel club) {
    return BentoCard(
      padding: const EdgeInsets.all(AppDimens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Achievements', icon: Icons.emoji_events_outlined),
          const SizedBox(height: AppDimens.md),
          ...club.achievements.map((ach) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.sm),
              child: Row(
                children: [
                  const Icon(Icons.star, color: AppColors.orangeDark, size: 20),
                  const SizedBox(width: AppDimens.sm),
                  Expanded(child: Text(ach, style: AppTextStyles.bodyMedium)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
