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
              color: AppColors.surfaceContainerHigh,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(club.logoUrl, fit: BoxFit.cover),
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
                const SizedBox(height: 2),
                Row(
                  children: [
                    StatusBadge.info(club.category.name.toUpperCase()),
                    const SizedBox(width: 8),
                    Text(
                      '• ${club.memberCount} Members',
                      style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.md),
                PrimaryButton(
                  label: club.isUserJoined ? 'Joined as ${club.userRole}' : 'Join Club',
                  icon: club.isUserJoined ? Icons.check : Icons.group_add,
                  isFullWidth: false,
                  backgroundColor: club.isUserJoined ? AppColors.blue : AppColors.green,
                  onPressed: club.isUserJoined
                      ? null
                      : () {
                          ClubController.instance.joinClub(club.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Joined ${club.name}! 🎉')),
                          );
                        },
                ),
              ],
            ),
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
