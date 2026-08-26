import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/team_model.dart';
import '../../shared/buttons/primary_button.dart';
import '../../shared/cards/bento_card.dart';
import '../../shared/chips/app_chips.dart';
import '../../shared/headers/section_header.dart';
import '../../state/team_controller.dart';

class TeamWorkspaceScreen extends StatefulWidget {
  final TeamModel team;

  const TeamWorkspaceScreen({super.key, required this.team});

  @override
  State<TeamWorkspaceScreen> createState() => _TeamWorkspaceScreenState();
}

class _TeamWorkspaceScreenState extends State<TeamWorkspaceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isPublicVisibility = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TeamController.instance,
      builder: (context, _) {
        final team = TeamController.instance.allTeams.firstWhere(
          (t) => t.id == widget.team.id,
          orElse: () => widget.team,
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            title: Text(
              team.name,
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.blue,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_add_outlined, color: AppColors.blue),
                onPressed: () => _showInviteDialog(context, team),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppColors.blue,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.blue,
              indicatorWeight: 3,
              labelStyle: AppTextStyles.titleLarge.copyWith(fontSize: 15),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Members'),
                Tab(text: 'Project & Files'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(context, team),
              _buildMembersTab(context, team),
              _buildProjectFilesTab(context, team),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewTab(BuildContext context, TeamModel team) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.marginMobile),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Summary Bento
            Row(
              children: [
                Expanded(
                  child: BentoCard(
                    padding: const EdgeInsets.all(AppDimens.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('LEADER', style: AppTextStyles.labelMedium),
                        const SizedBox(height: 2),
                        Text(team.leaderName, style: AppTextStyles.titleLarge.copyWith(fontSize: 15)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppDimens.sm),
                Expanded(
                  child: BentoCard(
                    padding: const EdgeInsets.all(AppDimens.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('MEMBERS', style: AppTextStyles.labelMedium),
                        const SizedBox(height: 2),
                        Text('${team.memberCount} Members', style: AppTextStyles.titleLarge.copyWith(fontSize: 15)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.lg),

            // Project Milestone Stepper
            BentoCard(
              padding: const EdgeInsets.all(AppDimens.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('🚀 Project Progress', style: AppTextStyles.headlineSmall),
                      StatusBadge.success('In Progress'),
                    ],
                  ),
                  const SizedBox(height: AppDimens.xs),
                  Text(
                    team.project?.title ?? 'Smart Campus Assistant',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppDimens.xl),
                  _buildMilestoneStepper(),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.lg),

            // Recent Activity
            SectionHeader(title: 'Recent Activity', icon: Icons.history),
            const SizedBox(height: AppDimens.sm),
            BentoCard(
              padding: const EdgeInsets.all(AppDimens.lg),
              child: Column(
                children: team.recentActivity.map((act) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppDimens.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(shape: BoxShape.circle),
                          clipBehavior: Clip.antiAlias,
                          child: Image.network(act.userAvatar, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: AppDimens.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: AppTextStyles.bodyMedium,
                                  children: [
                                    TextSpan(text: act.userName, style: const TextStyle(fontWeight: FontWeight.w700)),
                                    TextSpan(text: ' ${act.actionText}'),
                                  ],
                                ),
                              ),
                              Text(act.timeAgo, style: AppTextStyles.bodySmall.copyWith(fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppDimens.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneStepper() {
    final stages = ['Idea', 'Planning', 'Development', 'Testing', 'Completed'];
    const currentStep = 2; // Development

    return Row(
      children: List.generate(stages.length * 2 - 1, (index) {
        if (index.isOdd) {
          final isCompletedLine = index ~/ 2 < currentStep;
          return Expanded(
            child: Container(
              height: 3,
              color: isCompletedLine ? AppColors.green : AppColors.outlineVariant,
            ),
          );
        }

        final stepIndex = index ~/ 2;
        final isPassed = stepIndex < currentStep;
        final isCurrent = stepIndex == currentStep;

        return Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPassed
                    ? AppColors.green
                    : (isCurrent ? AppColors.white : AppColors.surfaceContainerLow),
                border: Border.all(
                  color: isPassed || isCurrent ? AppColors.green : AppColors.outlineVariant,
                  width: 2,
                ),
              ),
              child: Center(
                child: isPassed
                    ? const Icon(Icons.check, size: 18, color: AppColors.white)
                    : (isCurrent
                        ? const Icon(Icons.code, size: 16, color: AppColors.green)
                        : Text('${stepIndex + 1}', style: AppTextStyles.labelMedium)),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              stages[stepIndex],
              style: AppTextStyles.labelMedium.copyWith(
                color: isCurrent ? AppColors.green : AppColors.textSecondary,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMembersTab(BuildContext context, TeamModel team) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.marginMobile),
      child: Column(
        children: [
          ...team.members.map((m) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.md),
              child: BentoCard(
                padding: const EdgeInsets.all(AppDimens.md),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(m.avatarUrl, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: AppDimens.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(m.name, style: AppTextStyles.titleLarge.copyWith(fontSize: 16)),
                              if (m.isLeader) ...[
                                const SizedBox(width: 6),
                                StatusBadge.info('Leader'),
                              ],
                            ],
                          ),
                          Text(m.role, style: AppTextStyles.bodySmall.copyWith(color: AppColors.blue)),
                          Text('${m.branch} • Sem ${m.semester}', style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: AppDimens.lg),
          PrimaryButton(
            label: 'Invite New Member',
            icon: Icons.person_add,
            backgroundColor: AppColors.blue,
            onPressed: () => _showInviteDialog(context, team),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectFilesTab(BuildContext context, TeamModel team) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.marginMobile),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Details Card
          BentoCard(
            padding: const EdgeInsets.all(AppDimens.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Project Details', style: AppTextStyles.headlineSmall),
                    StatusBadge.warning('AI / ML'),
                  ],
                ),
                const SizedBox(height: AppDimens.md),
                Text('Problem Statement', style: AppTextStyles.titleLarge.copyWith(fontSize: 15)),
                Text(
                  team.project?.problem ?? 'Campus Navigation issues during rush hours.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppDimens.md),
                Text('Proposed Solution', style: AppTextStyles.titleLarge.copyWith(fontSize: 15)),
                Text(
                  team.project?.solution ?? 'Spatial AR wayfinding app with automated timetable sync.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppDimens.md),
                Wrap(
                  spacing: 6,
                  children: (team.project?.techStack ?? ['Flutter', 'Firebase', 'Python'])
                      .map((t) => SkillChip(label: t))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.lg),

          // Shared Files Card
          SectionHeader(title: 'Shared Files', icon: Icons.folder_shared_outlined),
          const SizedBox(height: AppDimens.sm),
          BentoCard(
            padding: const EdgeInsets.all(AppDimens.lg),
            child: Column(
              children: team.sharedFiles.map((file) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.md),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: file.fileType == FileType.pdf ? AppColors.redLight : AppColors.blueLight,
                          borderRadius: AppDimens.borderMd,
                        ),
                        child: Icon(
                          file.fileType == FileType.pdf
                              ? Icons.picture_as_pdf
                              : (file.fileType == FileType.video ? Icons.movie : Icons.code),
                          color: file.fileType == FileType.pdf ? AppColors.red : AppColors.blue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppDimens.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(file.title, style: AppTextStyles.titleLarge.copyWith(fontSize: 15)),
                            Text('${file.updatedTime} • ${file.fileSize}', style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.download, color: AppColors.blue),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Downloading ${file.title}')),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppDimens.lg),

          // Visibility Toggle
          BentoCard(
            padding: const EdgeInsets.all(AppDimens.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Public Showcase', style: AppTextStyles.titleLarge.copyWith(fontSize: 16)),
                    Text('Visible in campus directory', style: AppTextStyles.bodySmall),
                  ],
                ),
                Switch(
                  value: _isPublicVisibility,
                  activeThumbColor: AppColors.green,
                  onChanged: (val) => setState(() => _isPublicVisibility = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.xxl),
        ],
      ),
    );
  }

  void _showInviteDialog(BuildContext context, TeamModel team) {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Invite Teammate'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            hintText: 'Enter student USN or email',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invitation sent successfully!')),
              );
            },
            child: const Text('Send Invite'),
          ),
        ],
      ),
    );
  }
}
