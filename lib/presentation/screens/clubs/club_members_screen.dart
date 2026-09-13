import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/club_model.dart';
import '../../shared/cards/stat_card.dart';
import '../../state/auth_controller.dart';
import '../../state/club_controller.dart';
import 'add_member_modal.dart';
import 'edit_member_privileges_modal.dart';

class ClubMembersScreen extends StatefulWidget {
  final ClubModel club;

  const ClubMembersScreen({super.key, required this.club});

  @override
  State<ClubMembersScreen> createState() => _ClubMembersScreenState();
}

class _ClubMembersScreenState extends State<ClubMembersScreen> {
  final _searchController = TextEditingController();
  int _selectedFilterIndex =
      0; // 0: All, 1: Event Coordinators, 2: Core Team, 3: Members

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmRemoveMember(
    BuildContext context,
    ClubModel club,
    ClubMemberItem member,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: AppColors.red),
            SizedBox(width: 8),
            Text(
              'Remove Member',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to remove ${member.name} (${member.role}) from ${club.name}? They will lose all event and portal management privileges.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ClubController.instance.removeMemberFromClub(
                club.id,
                member.id,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Removed ${member.name} from club'),
                    backgroundColor: AppColors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        ClubController.instance,
        AuthController.instance,
      ]),
      builder: (context, _) {
        final currentClub = ClubController.instance.allClubs.firstWhere(
          (c) => c.id == widget.club.id,
          orElse: () => widget.club,
        );

        final members = currentClub.members;
        final eventCoordinatorsCount = members
            .where((m) => m.canManageEvents && !m.isManager)
            .length;
        final coreTeamCount = members
            .where(
              (m) =>
                  m.canPublish ||
                  m.role.toLowerCase().contains('core') ||
                  m.role.toLowerCase().contains('lead'),
            )
            .length;
        final generalCount = members
            .where((m) => !m.isManager && !m.canManageEvents && !m.canPublish)
            .length;

        final query = _searchController.text.trim().toLowerCase();
        final filteredMembers = members.where((m) {
          final matchesQuery =
              query.isEmpty ||
              m.name.toLowerCase().contains(query) ||
              m.role.toLowerCase().contains(query) ||
              m.branch.toLowerCase().contains(query) ||
              m.email.toLowerCase().contains(query) ||
              m.usn.toLowerCase().contains(query);

          if (_selectedFilterIndex == 1)
            return matchesQuery && m.canManageEvents;
          if (_selectedFilterIndex == 2)
            return matchesQuery && (m.canPublish || m.isManager);
          if (_selectedFilterIndex == 3)
            return matchesQuery && !m.isManager && !m.canManageEvents;
          return matchesQuery;
        }).toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: RefreshIndicator(
            onRefresh: () => ClubController.instance.loadClubs(),
            color: const Color(0xFF24389C),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.marginMobile,
                vertical: AppDimens.md,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Header Row with + Add Member
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Club Members',
                                style: AppTextStyles.headlineMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Manage team roles, event access, and privileges',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => AddMemberModal.show(
                            context,
                            clubId: currentClub.id,
                          ),
                          icon: const Icon(Icons.person_add, size: 18),
                          label: const Text('Add Member'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF24389C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.md),

                    // 4 Stat Cards
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth > 650;
                        return GridView.count(
                          crossAxisCount: isDesktop ? 4 : 2,
                          crossAxisSpacing: AppDimens.md,
                          mainAxisSpacing: AppDimens.md,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: isDesktop ? 1.5 : 1.3,
                          children: [
                            StatCard(
                              title: 'Total Members',
                              value: '${members.length}',
                              icon: Icons.groups,
                              iconColor: const Color(0xFF24389C),
                              subtitle: 'Active roster',
                            ),
                            StatCard(
                              title: 'Event Coordinators',
                              value: '$eventCoordinatorsCount',
                              icon: Icons.event_available,
                              iconColor: const Color(0xFF008744),
                              subtitle: 'Manage events',
                            ),
                            StatCard(
                              title: 'Core Leads',
                              value: '$coreTeamCount',
                              icon: Icons.stars,
                              iconColor: const Color(0xFFFFA700),
                              subtitle: 'Publishers & Leads',
                            ),
                            StatCard(
                              title: 'General Members',
                              value: '$generalCount',
                              icon: Icons.person_outline,
                              iconColor: const Color(0xFF5C5F60),
                              subtitle: 'Club attendees',
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: AppDimens.lg),

                    // Search Input
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search members by name, USN, email, role...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.outlineVariant,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.outlineVariant,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimens.sm),

                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            'All Members (${members.length})',
                            0,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Event Coordinators ($eventCoordinatorsCount)',
                            1,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip('Core Team ($coreTeamCount)', 2),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'General Members ($generalCount)',
                            3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimens.lg),

                    // Members List
                    if (filteredMembers.isEmpty)
                      _buildEmptyMembersState(context, currentClub.id)
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredMembers.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppDimens.md),
                        itemBuilder: (ctx, index) => _buildMemberCard(
                          context,
                          currentClub,
                          filteredMembers[index],
                        ),
                      ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedFilterIndex == index;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? Colors.white : AppColors.textSecondary,
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFF24389C),
      backgroundColor: AppColors.surface,
      side: BorderSide(
        color: isSelected ? const Color(0xFF24389C) : AppColors.outlineVariant,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (_) => setState(() => _selectedFilterIndex = index),
    );
  }

  Widget _buildEmptyMembersState(BuildContext context, String clubId) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF24389C).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.people_outline,
              size: 48,
              color: Color(0xFF24389C),
            ),
          ),
          const SizedBox(height: AppDimens.md),
          Text(
            'No Members Found',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add team members and grant them event management, response handling, and publishing privileges.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimens.lg),
          ElevatedButton.icon(
            onPressed: () => AddMemberModal.show(context, clubId: clubId),
            icon: const Icon(Icons.person_add, size: 18),
            label: const Text('Add Member'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF24389C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(
    BuildContext context,
    ClubModel club,
    ClubMemberItem member,
  ) {
    Color roleBadgeBg;
    Color roleBadgeText;

    if (member.isManager || member.role.toLowerCase().contains('leader')) {
      roleBadgeBg = const Color(0xFF008744).withValues(alpha: 0.12);
      roleBadgeText = const Color(0xFF008744);
    } else if (member.role.toLowerCase().contains('coordinator')) {
      roleBadgeBg = const Color(0xFF0057E7).withValues(alpha: 0.12);
      roleBadgeText = const Color(0xFF0057E7);
    } else if (member.role.toLowerCase().contains('lead')) {
      roleBadgeBg = const Color(0xFFFFA700).withValues(alpha: 0.15);
      roleBadgeText = const Color(0xFF8F4700);
    } else if (member.role.toLowerCase().contains('core')) {
      roleBadgeBg = const Color(0xFF24389C).withValues(alpha: 0.1);
      roleBadgeText = const Color(0xFF24389C);
    } else {
      roleBadgeBg = const Color(0xFF5C5F60).withValues(alpha: 0.1);
      roleBadgeText = const Color(0xFF5C5F60);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppDimens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF24389C).withValues(alpha: 0.1),
                  border: Border.all(
                    color: const Color(0xFF24389C).withValues(alpha: 0.2),
                  ),
                ),
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                child: member.avatarUrl.isNotEmpty
                    ? Image.network(
                        member.avatarUrl,
                        width: 46,
                        height: 46,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Text(
                          member.name.isNotEmpty
                              ? member.name[0].toUpperCase()
                              : 'M',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF24389C),
                          ),
                        ),
                      )
                    : Text(
                        member.name.isNotEmpty
                            ? member.name[0].toUpperCase()
                            : 'M',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF24389C),
                        ),
                      ),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            member.name,
                            style: AppTextStyles.titleLarge.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: roleBadgeBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            member.role,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: roleBadgeText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${member.branch} • Sem ${member.semester}${member.usn.isNotEmpty ? " • ${member.usn}" : ""}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    if (member.email.isNotEmpty)
                      Text(
                        member.email,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Privileges & Permissions Badges
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              if (member.canManageEvents)
                _buildPrivilegeBadge(
                  '🎟️ Event Access',
                  const Color(0xFF0057E7),
                ),
              if (member.canViewResponses)
                _buildPrivilegeBadge('📊 Responses', const Color(0xFF008744)),
              if (member.canCheckIn)
                _buildPrivilegeBadge('📱 Check-In', const Color(0xFF008744)),
              if (member.canPublish)
                _buildPrivilegeBadge('📢 Publish', const Color(0xFFFFA700)),
              if (member.canManageMembers)
                _buildPrivilegeBadge(
                  '👥 Members Admin',
                  const Color(0xFFD62D20),
                ),
              if (!member.canManageEvents &&
                  !member.canPublish &&
                  !member.canManageMembers)
                _buildPrivilegeBadge('👀 View Only', const Color(0xFF5C5F60)),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.outlineVariant, height: 1),
          const SizedBox(height: 8),

          // Action Buttons: Edit Privileges & Remove
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    EditMemberPrivilegesModal.show(
                      context,
                      clubId: club.id,
                      member: member,
                    );
                  },
                  icon: const Icon(Icons.shield_outlined, size: 16),
                  label: const Text(
                    'Edit Privileges',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF24389C),
                    side: const BorderSide(color: Color(0xFF24389C)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              if (!member.isManager) ...[
                const SizedBox(width: AppDimens.sm),
                OutlinedButton.icon(
                  onPressed: () => _confirmRemoveMember(context, club, member),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Remove', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.red,
                    side: const BorderSide(color: AppColors.red),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrivilegeBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
