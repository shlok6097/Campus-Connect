import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/team_model.dart';
import '../../shared/buttons/primary_button.dart';
import '../../shared/cards/bento_card.dart';
import '../../shared/chips/app_chips.dart';
import '../../shared/headers/section_header.dart';

class ProjectDetailsScreen extends StatelessWidget {
  final ProjectModel project;
  final TeamModel team;

  const ProjectDetailsScreen({
    super.key,
    required this.project,
    required this.team,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: Text(
          project.title,
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.blue,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.marginMobile),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project Hero
              BentoCard(
                padding: const EdgeInsets.all(AppDimens.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          project.title,
                          style: AppTextStyles.displayLargeMobile.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        StatusBadge.info(project.category),
                      ],
                    ),
                    const SizedBox(height: AppDimens.sm),
                    Text(
                      project.problem,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.lg),

              // Solution & Architecture
              SectionHeader(title: 'Proposed Solution', icon: Icons.lightbulb_outline),
              const SizedBox(height: AppDimens.sm),
              BentoCard(
                padding: const EdgeInsets.all(AppDimens.lg),
                child: Text(
                  project.solution,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.lg),

              // Tech Stack
              SectionHeader(title: 'Tech Stack', icon: Icons.code),
              const SizedBox(height: AppDimens.sm),
              BentoCard(
                padding: const EdgeInsets.all(AppDimens.lg),
                child: Wrap(
                  spacing: AppDimens.sm,
                  runSpacing: AppDimens.sm,
                  children: project.techStack.map((tech) => SkillChip(label: tech)).toList(),
                ),
              ),
              const SizedBox(height: AppDimens.lg),

              // Looking for Roles
              if (project.lookingForRoles.isNotEmpty) ...[
                SectionHeader(title: 'Looking For', icon: Icons.person_search),
                const SizedBox(height: AppDimens.sm),
                BentoCard(
                  padding: const EdgeInsets.all(AppDimens.lg),
                  child: Column(
                    children: project.lookingForRoles.map((role) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppDimens.sm),
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_right, color: AppColors.blue, size: 24),
                            const SizedBox(width: 4),
                            Text(
                              role,
                              style: AppTextStyles.titleLarge.copyWith(fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: AppDimens.lg),
              ],

              // Team Members
              SectionHeader(title: 'Team Members', icon: Icons.group_outlined),
              const SizedBox(height: AppDimens.sm),
              BentoCard(
                padding: const EdgeInsets.all(AppDimens.lg),
                child: Column(
                  children: team.members.map((m) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppDimens.md),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(shape: BoxShape.circle),
                            clipBehavior: Clip.antiAlias,
                            child: Image.network(m.avatarUrl, fit: BoxFit.cover),
                          ),
                          const SizedBox(width: AppDimens.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m.name, style: AppTextStyles.titleLarge.copyWith(fontSize: 15)),
                                Text(m.role, style: AppTextStyles.bodySmall),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppDimens.xl),

              // Primary CTA
              PrimaryButton(
                label: 'Request to Join Team',
                icon: Icons.send,
                backgroundColor: AppColors.green,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Join request sent to ${team.leaderName}!')),
                  );
                },
              ),
              const SizedBox(height: AppDimens.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
