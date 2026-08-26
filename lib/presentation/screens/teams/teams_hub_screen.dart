import 'package:flutter/material.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/team_model.dart';
import '../../shared/buttons/primary_button.dart';
import '../../shared/buttons/secondary_button.dart';
import '../../shared/cards/bento_card.dart';
import '../../shared/chips/app_chips.dart';
import '../../shared/headers/screen_header.dart';
import '../../shared/headers/section_header.dart';
import '../../shared/inputs/app_search_bar.dart';
import '../../state/team_controller.dart';
import 'team_workspace_screen.dart';
import 'project_details_screen.dart';
import 'showcase_project_screen.dart';

class TeamsHubScreen extends StatefulWidget {
  const TeamsHubScreen({super.key});

  @override
  State<TeamsHubScreen> createState() => _TeamsHubScreenState();
}

class _TeamsHubScreenState extends State<TeamsHubScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          'Teams & Projects',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: TeamController.instance,
        builder: (context, _) {
          final myTeam = TeamController.instance.myTeam;
          final discoverTeams = TeamController.instance.discoverTeams;

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
                  // Header
                  Wrap(
                    spacing: AppDimens.md,
                    runSpacing: AppDimens.sm,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const ScreenHeader(
                        title: 'Teams & Projects',
                        subtitle: 'Find teammates, build projects, and collaborate',
                      ),
                      PrimaryButton(
                        label: 'Showcase Project',
                        icon: Icons.add,
                        isFullWidth: false,
                        backgroundColor: AppColors.blue,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ShowcaseProjectScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.lg),

                  // Search Bar
                  AppSearchBar(
                    hint: 'Search teams, projects, or required skills...',
                    controller: _searchController,
                    onChanged: (val) => TeamController.instance.setSearchQuery(val),
                  ),
                  const SizedBox(height: AppDimens.xl),

                  // 1. My Team Highlight Card (Team Nova)
                  SectionHeader(
                    title: 'My Workspace',
                    icon: Icons.workspace_premium_outlined,
                  ),
                  const SizedBox(height: AppDimens.sm),
                  _buildMyTeamCard(context, myTeam),
                  const SizedBox(height: AppDimens.xl),

                  // 2. Discover Teams (Looking for Teammates)
                  SectionHeader(
                    title: 'Discover Teams',
                    icon: Icons.explore_outlined,
                  ),
                  const SizedBox(height: AppDimens.sm),
                  _buildDiscoverTeamsList(context, discoverTeams),
                  const SizedBox(height: AppDimens.xl),

                  // 3. Find Teammates (Directory of Available Students)
                  SectionHeader(
                    title: 'Find Teammates',
                    icon: Icons.person_search_outlined,
                  ),
                  const SizedBox(height: AppDimens.sm),
                  _buildFindTeammatesSection(context),
                  const SizedBox(height: AppDimens.xxl),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMyTeamCard(BuildContext context, TeamModel team) {
    return BentoCard(
      padding: const EdgeInsets.all(AppDimens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.name,
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'for ${team.eventName}',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.blue),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge.success('${team.memberCount} Members'),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          if (team.project != null) ...[
            Text(
              'Project: ${team.project!.title}',
              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              team.project!.problem,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppDimens.md),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: team.project!.techStack.map((tech) => SkillChip(label: tech)).toList(),
            ),
          ],
          const SizedBox(height: AppDimens.lg),
          // Member Avatars Stack & Action
          Wrap(
            spacing: AppDimens.md,
            runSpacing: AppDimens.sm,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                height: 36,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: team.members.map((m) {
                    return Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(m.avatarUrl, fit: BoxFit.cover),
                    );
                  }).toList(),
                ),
              ),
              PrimaryButton(
                label: 'Open Workspace',
                icon: Icons.launch,
                isFullWidth: false,
                backgroundColor: AppColors.blue,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => TeamWorkspaceScreen(team: team)),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverTeamsList(BuildContext context, List<TeamModel> teams) {
    return Column(
      children: teams.map((team) {
        return Padding(
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
                        team.name,
                        style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge.warning('Looking for 2 Members'),
                  ],
                ),
                const SizedBox(height: AppDimens.xs),
                if (team.project != null)
                  Text(
                    team.project!.solution,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: AppDimens.md),
                Wrap(
                  spacing: AppDimens.md,
                  runSpacing: AppDimens.sm,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Leader: ${team.leaderName}',
                      style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                    ),
                    SecondaryButton(
                      label: 'View Project',
                      icon: Icons.visibility_outlined,
                      isFullWidth: false,
                      onPressed: () {
                        if (team.project != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProjectDetailsScreen(project: team.project!, team: team),
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
        );
      }).toList(),
    );
  }

  Widget _buildFindTeammatesSection(BuildContext context) {
    final students = [
      {'name': 'Ananya Sharma', 'dept': 'ISE • Sem 6', 'skills': ['UI/UX', 'Figma', 'Flutter'], 'avatar': AssetConstants.avatarAnanya},
      {'name': 'Kiran Patil', 'dept': 'ECE • Sem 6', 'skills': ['Python', 'TensorFlow', 'OpenCV'], 'avatar': AssetConstants.avatarKiran},
      {'name': 'Priya Rao', 'dept': 'CSE • Sem 6', 'skills': ['Flutter', 'Node.js', 'Firebase'], 'avatar': AssetConstants.avatarPriya},
    ];

    return Column(
      children: students.map((s) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimens.sm),
          child: BentoCard(
            padding: const EdgeInsets.all(AppDimens.md),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(s['avatar'] as String, fit: BoxFit.cover),
                ),
                const SizedBox(width: AppDimens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s['name'] as String, style: AppTextStyles.titleLarge.copyWith(fontSize: 16)),
                      Text(s['dept'] as String, style: AppTextStyles.bodySmall),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children: (s['skills'] as List<String>)
                            .map((sk) => SkillChip(label: sk, backgroundColor: AppColors.surfaceContainerHigh))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Invited ${s['name']} to team')),
                    );
                  },
                  child: const Text('Invite'),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
