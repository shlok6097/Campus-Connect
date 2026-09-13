import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/club_model.dart';
import '../../shared/buttons/primary_button.dart';
import '../../state/club_controller.dart';

class EditMemberPrivilegesModal extends StatefulWidget {
  final String clubId;
  final ClubMemberItem member;

  const EditMemberPrivilegesModal({
    super.key,
    required this.clubId,
    required this.member,
  });

  static Future<void> show(BuildContext context, {required String clubId, required ClubMemberItem member}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditMemberPrivilegesModal(clubId: clubId, member: member),
    );
  }

  @override
  State<EditMemberPrivilegesModal> createState() => _EditMemberPrivilegesModalState();
}

class _EditMemberPrivilegesModalState extends State<EditMemberPrivilegesModal> {
  late String _selectedRole;
  late Set<String> _selectedPrivileges;
  bool _isSaving = false;

  final List<String> _availableRoles = [
    'Club Leader',
    'Event Coordinator',
    'Technical Lead',
    'Core Member',
    'Member',
  ];

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.member.role.isNotEmpty ? widget.member.role : 'Member';
    if (!_availableRoles.contains(_selectedRole)) {
      _selectedRole = widget.member.isManager ? 'Club Leader' : 'Member';
    }
    _selectedPrivileges = Set<String>.from(widget.member.privileges);
    if (widget.member.isManager) {
      _selectedPrivileges.addAll([
        'manage_events',
        'view_responses',
        'publish_content',
        'manage_members',
        'checkin_attendees',
      ]);
    }
  }

  void _onRoleChanged(String? newRole) {
    if (newRole == null) return;
    setState(() {
      _selectedRole = newRole;
      if (newRole == 'Club Leader') {
        _selectedPrivileges = {
          'manage_events',
          'view_responses',
          'publish_content',
          'manage_members',
          'checkin_attendees',
        };
      } else if (newRole == 'Event Coordinator') {
        _selectedPrivileges = {
          'manage_events',
          'view_responses',
          'checkin_attendees',
        };
      } else if (newRole == 'Technical Lead') {
        _selectedPrivileges = {
          'publish_content',
          'manage_events',
        };
      } else if (newRole == 'Core Member') {
        _selectedPrivileges = {
          'publish_content',
        };
      } else {
        _selectedPrivileges = {'view_events'};
      }
    });
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);

    final isManager = _selectedRole == 'Club Leader';
    await ClubController.instance.updateMemberRoleAndPrivileges(
      widget.clubId,
      widget.member.id,
      _selectedRole,
      isManager,
      _selectedPrivileges.toList(),
    );

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('Privileges updated for ${widget.member.name}'),
            ],
          ),
          backgroundColor: const Color(0xFF008744),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: AppDimens.md,
        left: AppDimens.md,
        right: AppDimens.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppDimens.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: AppDimens.md),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manage Member Privileges',
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.member.name,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(color: AppColors.outlineVariant, height: 1),
            const SizedBox(height: AppDimens.md),

            // Role Dropdown
            Text(
              'Assign Club Role',
              style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.outlineVariant),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedRole,
                  isExpanded: true,
                  items: _availableRoles.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role, style: const TextStyle(fontWeight: FontWeight.w600)),
                    );
                  }).toList(),
                  onChanged: _onRoleChanged,
                ),
              ),
            ),
            const SizedBox(height: AppDimens.lg),

            // Access & Privileges Section
            Text(
              'Event & Portal Permissions',
              style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Control what this member can view, manage, and publish in your club.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimens.sm),

            _buildPrivilegeTile(
              keyName: 'manage_events',
              title: 'Manage Events',
              subtitle: 'Create, edit, and publish club events',
              icon: Icons.event_available,
              color: const Color(0xFF24389C),
            ),
            _buildPrivilegeTile(
              keyName: 'view_responses',
              title: 'View Event Responses & Payments',
              subtitle: 'Access attendee lists, verify UPI fees, and export data',
              icon: Icons.assignment_turned_in_outlined,
              color: const Color(0xFF008744),
            ),
            _buildPrivilegeTile(
              keyName: 'checkin_attendees',
              title: 'Attendee Check-In & Scanner',
              subtitle: 'Mark attendee entry and scan event QR tickets',
              icon: Icons.qr_code_scanner,
              color: const Color(0xFF0057E7),
            ),
            _buildPrivilegeTile(
              keyName: 'publish_content',
              title: 'Publish Hub Access',
              subtitle: 'Post announcements, quizzes, polls, documents, and news',
              icon: Icons.post_add,
              color: const Color(0xFFFFA700),
            ),
            _buildPrivilegeTile(
              keyName: 'manage_members',
              title: 'Member Administration',
              subtitle: 'Add/remove members and assign permissions',
              icon: Icons.manage_accounts_outlined,
              color: const Color(0xFFD62D20),
            ),
            const SizedBox(height: AppDimens.lg),

            // Save Button
            PrimaryButton(
              label: _isSaving ? 'Saving...' : 'Save Privileges',
              icon: Icons.save_outlined,
              backgroundColor: const Color(0xFF24389C),
              isLoading: _isSaving,
              onPressed: _handleSave,
            ),
            const SizedBox(height: AppDimens.sm),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivilegeTile({
    required String keyName,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isEnabled = _selectedPrivileges.contains(keyName);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isEnabled ? color.withValues(alpha: 0.05) : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled ? color.withValues(alpha: 0.3) : AppColors.outlineVariant,
        ),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        value: isEnabled,
        activeColor: color,
        onChanged: (val) {
          setState(() {
            if (val) {
              _selectedPrivileges.add(keyName);
            } else {
              _selectedPrivileges.remove(keyName);
            }
          });
        },
      ),
    );
  }
}
