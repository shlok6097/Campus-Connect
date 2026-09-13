import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/user_model.dart';
import '../../shared/buttons/primary_button.dart';
import '../../shared/buttons/secondary_button.dart';
import '../../shared/cards/bento_card.dart';
import '../../shared/chips/app_chips.dart';
import '../../shared/headers/section_header.dart';
import '../../state/auth_controller.dart';
import '../../state/team_controller.dart';
import '../auth/login_screen.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AuthController.instance,
      builder: (context, _) {
        final user = AuthController.instance.currentUser;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.marginMobile,
            vertical: AppDimens.lg,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Identity & Highlights Bento Row
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth > 700;
                    if (isDesktop) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildIdentityCard(context, user),
                          ),
                          const SizedBox(width: AppDimens.md),
                          Expanded(flex: 2, child: _buildHighlightsCard(user)),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        _buildIdentityCard(context, user),
                        const SizedBox(height: AppDimens.md),
                        _buildHighlightsCard(user),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppDimens.xl),

                // 2. Two-Column Layout for About/Skills and Projects
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth > 700;
                    if (isDesktop) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                _buildAboutCard(user),
                                const SizedBox(height: AppDimens.md),
                                _buildSkillsCard(user),
                                const SizedBox(height: AppDimens.md),
                                _buildAchievementsCard(user),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppDimens.md),
                          Expanded(flex: 3, child: _buildProjectsSection()),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        _buildAboutCard(user),
                        const SizedBox(height: AppDimens.md),
                        _buildSkillsCard(user),
                        const SizedBox(height: AppDimens.md),
                        _buildAchievementsCard(user),
                        const SizedBox(height: AppDimens.xl),
                        _buildProjectsSection(),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppDimens.xxl),

                // Account Actions (Logout)
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      AuthController.instance.logout();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(
                      Icons.logout,
                      color: AppColors.red,
                      size: 18,
                    ),
                    label: Text(
                      'Log Out of Campus Connect',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.red),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.xl,
                        vertical: AppDimens.md,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.xxl),

                // Footer
                Center(
                  child: Text(
                    'Powered by GDG UVCE',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.outline,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.lg),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIdentityCard(BuildContext context, UserModel user) {
    return BentoCard(
      padding: const EdgeInsets.all(AppDimens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.blueLight,
                  border: Border.all(color: AppColors.outlineVariant, width: 2),
                ),
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                child: user.avatarUrl.isNotEmpty
                    ? Image.network(
                        user.avatarUrl,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blue,
                          ),
                        ),
                      )
                    : Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
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
                      user.name,
                      style: AppTextStyles.displayLargeMobile.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.endingYear > 0
                          ? '${user.branch} • Batch of ${user.endingYear}'
                          : '${user.branch} • Semester ${user.semester}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (user.studentId.isNotEmpty) ...[
                          const Icon(
                            Icons.badge_outlined,
                            size: 16,
                            color: AppColors.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ID: ${user.studentId}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        StatusBadge.info(user.role.displayName),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.lg),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'Edit Profile',
                  icon: Icons.edit_outlined,
                  backgroundColor: AppColors.blue,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile details are up to date!'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppDimens.sm),
              Expanded(
                child: SecondaryButton(
                  label: 'Share Portfolio',
                  icon: Icons.share_outlined,
                  color: AppColors.blue,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copied portfolio link for ${user.name}'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightsCard(UserModel user) {
    return BentoCard(
      padding: const EdgeInsets.all(AppDimens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Looking For',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimens.sm),
          if (user.lookingFor.isEmpty)
            Text(
              'Hackathons, Technical Projects, Study Groups',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            )
          else
            Wrap(
              spacing: AppDimens.xs + 2,
              runSpacing: AppDimens.xs + 2,
              children: user.lookingFor.map<Widget>((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.orangeLight,
                    borderRadius: AppDimens.borderPill,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.psychology,
                        size: 14,
                        color: AppColors.orangeDark,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tag,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.orangeDark,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          const Divider(height: AppDimens.xl),
          Text(
            'Availability',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimens.sm),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: user.isAvailableForTeams ? AppColors.green : AppColors.outline,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                user.isAvailableForTeams ? 'Actively seeking teams' : 'Not currently looking',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: user.isAvailableForTeams ? AppColors.greenDark : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(UserModel user) {
    return BentoCard(
      padding: const EdgeInsets.all(AppDimens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline, color: AppColors.blue, size: 20),
              const SizedBox(width: AppDimens.sm),
              Text(
                'About Me',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sm),
          Text(
            user.bio.isNotEmpty
                ? user.bio
                : 'Student at UVCE passionate about engineering, collaborative projects, and campus initiatives.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsCard(UserModel user) {
    return BentoCard(
      padding: const EdgeInsets.all(AppDimens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt_outlined, color: AppColors.blue, size: 20),
              const SizedBox(width: AppDimens.sm),
              Text(
                'Skills',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          if (user.skills.isEmpty)
            Text(
              'No skills added yet.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            )
          else
            Wrap(
              spacing: AppDimens.sm,
              runSpacing: AppDimens.sm,
              children: user.skills.map<Widget>((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.blueLight,
                    borderRadius: AppDimens.borderMd,
                    border: Border.all(color: AppColors.blue.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    skill,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.blueDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildAchievementsCard(UserModel user) {
    return BentoCard(
      padding: const EdgeInsets.all(AppDimens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_events_outlined,
                color: AppColors.orangeDark,
                size: 20,
              ),
              const SizedBox(width: AppDimens.sm),
              Text(
                'Achievements',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          if (user.achievements.isEmpty)
            Text(
              'No achievements listed yet. Participate in campus events to earn badges!',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            )
          else
            ...user.achievements.map<Widget>((ach) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.orangeLight,
                        borderRadius: AppDimens.borderSm,
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        size: 20,
                        color: AppColors.orangeDark,
                      ),
                    ),
                    const SizedBox(width: AppDimens.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ach.title,
                            style: AppTextStyles.titleLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            ach.issuer,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
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

  Widget _buildProjectsSection() {
    final teamProjects = TeamController.instance.allTeams
        .where((t) => t.project != null)
        .map((t) => t.project!)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Projects Showcase',
          icon: Icons.folder_open_outlined,
        ),
        const SizedBox(height: AppDimens.md),
        if (teamProjects.isEmpty)
          BentoCard(
            padding: const EdgeInsets.all(AppDimens.xl),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.code, size: 36, color: AppColors.outline),
                  const SizedBox(height: AppDimens.sm),
                  Text(
                    'No projects showcased yet',
                    style: AppTextStyles.titleLarge.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Join or create a team to showcase your innovative projects here.',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...teamProjects.map((proj) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.md),
                child: BentoCard(
                  padding: const EdgeInsets.all(AppDimens.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              proj.title,
                              style: AppTextStyles.titleLarge.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.blue,
                              ),
                            ),
                          ),
                          StatusBadge.success(proj.stage.name.toUpperCase()),
                        ],
                      ),
                      const SizedBox(height: AppDimens.xs),
                      Text(
                        proj.solution.isNotEmpty ? proj.solution : proj.problem,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimens.md),
                      Wrap(
                        spacing: 6,
                        children: proj.techStack.map((tech) => SkillChip(
                          label: tech,
                          backgroundColor: AppColors.surfaceContainerHigh,
                          textColor: AppColors.textPrimary,
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              )),
      ],
    );
  }
}
