import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/club_model.dart';
import '../../shared/cards/bento_card.dart';
import '../../shared/chips/app_chips.dart';
import '../../shared/inputs/app_search_bar.dart';
import '../../state/club_controller.dart';

class ClubMembersScreen extends StatefulWidget {
  final ClubModel club;

  const ClubMembersScreen({super.key, required this.club});

  @override
  State<ClubMembersScreen> createState() => _ClubMembersScreenState();
}

class _ClubMembersScreenState extends State<ClubMembersScreen> {
  final _searchController = TextEditingController();
  int _selectedFilterIndex = 0; // 0: All, 1: Managers, 2: Members

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ClubController.instance,
      builder: (context, _) {
        final currentClub = ClubController.instance.allClubs.firstWhere(
          (c) => c.id == widget.club.id,
          orElse: () => widget.club,
        );

        final query = _searchController.text.toLowerCase();
        final filteredMembers = currentClub.members.where((m) {
          final matchesQuery = query.isEmpty ||
              m.name.toLowerCase().contains(query) ||
              m.role.toLowerCase().contains(query) ||
              m.branch.toLowerCase().contains(query);

          if (_selectedFilterIndex == 1) return matchesQuery && m.isManager;
          if (_selectedFilterIndex == 2) return matchesQuery && !m.isManager;
          return matchesQuery;
        }).toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            title: Text(
              '${currentClub.name} Roster',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.blue,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.marginMobile),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search & Actions
                  AppSearchBar(
                    hint: 'Search members by name or branch...',
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppDimens.md),

                  // Filter Tabs
                  Row(
                    children: [
                      _buildFilterChip('All Members (${currentClub.members.length})', 0),
                      const SizedBox(width: AppDimens.sm),
                      _buildFilterChip('Managers', 1),
                      const SizedBox(width: AppDimens.sm),
                      _buildFilterChip('Members', 2),
                    ],
                  ),
                  const SizedBox(height: AppDimens.lg),

                  // Members Bento Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth > 650;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isDesktop ? 2 : 1,
                          crossAxisSpacing: AppDimens.md,
                          mainAxisSpacing: AppDimens.md,
                          childAspectRatio: isDesktop ? 1.7 : 1.6,
                        ),
                        itemCount: filteredMembers.length,
                        itemBuilder: (ctx, index) => _buildMemberCard(context, currentClub, filteredMembers[index]),
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

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedFilterIndex == index;
    return Material(
      color: isSelected ? AppColors.blue : AppColors.white,
      shape: StadiumBorder(
        side: BorderSide(color: isSelected ? AppColors.blue : AppColors.outlineVariant),
      ),
      child: InkWell(
        onTap: () => setState(() => _selectedFilterIndex = index),
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: AppDimens.sm),
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: isSelected ? AppColors.white : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, ClubModel club, ClubMemberItem member) {
    return BentoCard(
      padding: const EdgeInsets.all(AppDimens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                clipBehavior: Clip.antiAlias,
                child: Image.network(member.avatarUrl, fit: BoxFit.cover),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(member.name, style: AppTextStyles.titleLarge.copyWith(fontSize: 16)),
                    Text('${member.branch} • Sem ${member.semester}', style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              StatusBadge.info(member.role),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.calendar_month, size: 14, color: AppColors.outline),
              const SizedBox(width: 4),
              Text('Joined ${member.joinedDate}', style: AppTextStyles.bodySmall.copyWith(fontSize: 12)),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Updated role for ${member.name}')),
                    );
                  },
                  child: const Text('Change Role'),
                ),
              ),
              const SizedBox(width: AppDimens.sm),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ClubController.instance.removeMemberFromClub(club.id, member.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Removed ${member.name} from club')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.red,
                    side: const BorderSide(color: AppColors.red),
                  ),
                  child: const Text('Remove'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
