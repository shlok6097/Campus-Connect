import 'package:flutter/material.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../shared/buttons/primary_button.dart';
import '../../shared/buttons/secondary_button.dart';
import '../../shared/cards/bento_card.dart';
import '../../shared/chips/app_chips.dart';
import '../../shared/headers/section_header.dart';
import '../../state/auth_controller.dart';
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

  Widget _buildIdentityCard(BuildContext context, user) {
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
                  color: AppColors.surfaceContainerHigh,
                  border: Border.all(color: AppColors.outlineVariant, width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  user.avatarUrl.isNotEmpty
                      ? user.avatarUrl
                      : AssetConstants.avatarRahul,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.person, color: AppColors.blue, size: 48),
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
                      '${user.branch} • Semester ${user.semester}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.badge_outlined,
                          size: 16,
                          color: AppColors.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Student ID: ${user.studentId}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
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

  Widget _buildHighlightsCard(user) {
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
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Actively seeking teams',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.greenDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(user) {
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
            user.bio,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsCard(user) {
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
                  border: Border.all(color: AppColors.blue.withOpacity(0.3)),
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

  Widget _buildAchievementsCard(user) {
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
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildProjectsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Projects Showcase',
          icon: Icons.folder_open_outlined,
        ),
        const SizedBox(height: AppDimens.md),
        BentoCard(
          padding: const EdgeInsets.all(AppDimens.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Campus Navigation App',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.blue,
                    ),
                  ),
                  StatusBadge.success('Active'),
                ],
              ),
              const SizedBox(height: AppDimens.xs),
              Text(
                'A cross-platform mobile application to help students discover and register for campus events. Built with Flutter and Firebase.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimens.md),
              Wrap(
                spacing: 6,
                children: [
                  SkillChip(
                    label: 'Flutter',
                    backgroundColor: AppColors.surfaceContainerHigh,
                    textColor: AppColors.textPrimary,
                  ),
                  SkillChip(
                    label: 'Firebase',
                    backgroundColor: AppColors.surfaceContainerHigh,
                    textColor: AppColors.textPrimary,
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.md),
              Text(
                'Role: Lead Developer',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.md),
        BentoCard(
          padding: const EdgeInsets.all(AppDimens.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'AI Study Assistant',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.blue,
                    ),
                  ),
                  StatusBadge.info('Completed'),
                ],
              ),
              const SizedBox(height: AppDimens.xs),
              Text(
                'A web-based tool that uses NLP to summarize lecture notes and generate practice quizzes automatically.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimens.md),
              Wrap(
                spacing: 6,
                children: [
                  SkillChip(
                    label: 'Python',
                    backgroundColor: AppColors.surfaceContainerHigh,
                    textColor: AppColors.textPrimary,
                  ),
                  SkillChip(
                    label: 'React',
                    backgroundColor: AppColors.surfaceContainerHigh,
                    textColor: AppColors.textPrimary,
                  ),
                  SkillChip(
                    label: 'OpenAI API',
                    backgroundColor: AppColors.surfaceContainerHigh,
                    textColor: AppColors.textPrimary,
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.md),
              Text(
                'Role: Backend Engineer',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
