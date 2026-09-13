import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/club_model.dart';
import '../../shared/buttons/primary_button.dart';
import '../../state/club_controller.dart';

class AddMemberModal extends StatefulWidget {
  final String clubId;

  const AddMemberModal({super.key, required this.clubId});

  static Future<void> show(BuildContext context, {required String clubId}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddMemberModal(clubId: clubId),
    );
  }

  @override
  State<AddMemberModal> createState() => _AddMemberModalState();
}

class _AddMemberModalState extends State<AddMemberModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usnController = TextEditingController();
  final _branchController = TextEditingController(text: 'Computer Science');
  int _semester = 4;

  String _selectedRole = 'Event Coordinator';
  Set<String> _selectedPrivileges = {
    'manage_events',
    'view_responses',
    'checkin_attendees',
  };

  List<Map<String, dynamic>> _availableStudents = [];
  bool _isLoadingStudents = true;
  Map<String, dynamic>? _selectedStudent;

  bool _isSubmitting = false;

  final List<String> _roles = [
    'Event Coordinator',
    'Technical Lead',
    'Core Member',
    'Member',
    'Club Leader',
  ];

  @override
  void initState() {
    super.initState();
    _loadAvailableStudents();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usnController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableStudents() async {
    final list = await ClubController.instance.fetchAvailableStudents(widget.clubId);
    if (mounted) {
      setState(() {
        _availableStudents = list;
        _isLoadingStudents = false;
      });
    }
  }

  void _onStudentPicked(Map<String, dynamic>? student) {
    setState(() {
      _selectedStudent = student;
      if (student != null) {
        _nameController.text = (student['full_name'] ?? student['name'] ?? '').toString();
        _emailController.text = (student['email'] ?? '').toString();
        _usnController.text = (student['usn'] ?? '').toString();
        _branchController.text = (student['branch'] ?? 'Computer Science').toString();
        _semester = student['semester'] as int? ?? 4;
      }
    });
  }

  void _onRoleChanged(String? role) {
    if (role == null) return;
    setState(() {
      _selectedRole = role;
      if (role == 'Event Coordinator') {
        _selectedPrivileges = {'manage_events', 'view_responses', 'checkin_attendees'};
      } else if (role == 'Technical Lead') {
        _selectedPrivileges = {'publish_content', 'manage_events'};
      } else if (role == 'Core Member') {
        _selectedPrivileges = {'publish_content'};
      } else if (role == 'Club Leader') {
        _selectedPrivileges = {
          'manage_events',
          'view_responses',
          'publish_content',
          'manage_members',
          'checkin_attendees',
        };
      } else {
        _selectedPrivileges = {'view_events'};
      }
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final userId = _selectedStudent?['id'] ?? 'user_${DateTime.now().millisecondsSinceEpoch}';
    final isManager = _selectedRole == 'Club Leader';

    final member = ClubMemberItem(
      id: userId,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      usn: _usnController.text.trim(),
      role: _selectedRole,
      branch: _branchController.text.trim().isNotEmpty ? _branchController.text.trim() : 'CSE',
      semester: _semester,
      avatarUrl: _selectedStudent?['avatar_url'] ?? '',
      joinedDate: 'Today',
      isManager: isManager,
      privileges: _selectedPrivileges.toList(),
    );

    await ClubController.instance.addMemberToClub(widget.clubId, member);

    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('${member.name} added to club as $_selectedRole!'),
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
      child: Form(
        key: _formKey,
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
                  Text(
                    'Add Club Member',
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(color: AppColors.outlineVariant, height: 1),
              const SizedBox(height: AppDimens.md),

              // Quick Pick from Campus Directory if available
              if (_availableStudents.isNotEmpty) ...[
                Text(
                  'Quick Select from Campus Directory',
                  style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF24389C).withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF24389C).withValues(alpha: 0.04),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Map<String, dynamic>>(
                      value: _selectedStudent,
                      hint: const Text('Choose a student profile...'),
                      isExpanded: true,
                      items: _availableStudents.map((s) {
                        final name = s['full_name'] ?? s['name'] ?? 'Student';
                        final email = s['email'] ?? '';
                        return DropdownMenuItem(
                          value: s,
                          child: Text('$name ($email)', style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: _onStudentPicked,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.md),
                const Center(
                  child: Text(
                    '— OR ENTER MANUALLY —',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: AppDimens.md),
              ],

              // Full Name
              Text('Full Name', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'e.g. Priya Sharma',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter member name' : null,
              ),
              const SizedBox(height: AppDimens.md),

              // Email & USN Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'student@uvce.edu',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimens.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('USN', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _usnController,
                          decoration: InputDecoration(
                            hintText: '1UV22CS045',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.md),

              // Branch & Semester Row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Branch', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _branchController,
                          decoration: InputDecoration(
                            hintText: 'Information Science',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimens.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Semester', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<int>(
                          value: _semester,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          items: [1, 2, 3, 4, 5, 6, 7, 8].map((s) {
                            return DropdownMenuItem(value: s, child: Text('Sem $s'));
                          }).toList(),
                          onChanged: (val) => setState(() => _semester = val ?? 4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.lg),

              // Role
              Text('Club Role', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold)),
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
                    items: _roles.map((r) {
                      return DropdownMenuItem(
                        value: r,
                        child: Text(r, style: const TextStyle(fontWeight: FontWeight.w600)),
                      );
                    }).toList(),
                    onChanged: _onRoleChanged,
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.lg),

              // Privileges Checkboxes
              Text(
                'Assign Event & Administrative Privileges',
                style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),

              _buildPrivilegeCheckbox(
                'manage_events',
                'Manage Events',
                'Allow creating, editing, and publishing club events',
                Icons.event_available,
              ),
              _buildPrivilegeCheckbox(
                'view_responses',
                'View Responses & Payments',
                'Access registrations, verify payments, and export CSV/Excel',
                Icons.assignment_turned_in_outlined,
              ),
              _buildPrivilegeCheckbox(
                'checkin_attendees',
                'Check-In & QR Scanner',
                'Scan QR tickets and mark attendance at event venues',
                Icons.qr_code_scanner,
              ),
              _buildPrivilegeCheckbox(
                'publish_content',
                'Publishing Access',
                'Post quizzes, polls, news, and technical facts on club feed',
                Icons.post_add,
              ),
              _buildPrivilegeCheckbox(
                'manage_members',
                'Manage Members',
                'Add, remove, and configure club member permissions',
                Icons.manage_accounts_outlined,
              ),
              const SizedBox(height: AppDimens.lg),

              // Submit Button
              PrimaryButton(
                label: _isSubmitting ? 'Adding Member...' : 'Add Member to Club',
                icon: Icons.person_add,
                backgroundColor: const Color(0xFF24389C),
                isLoading: _isSubmitting,
                onPressed: _handleSubmit,
              ),
              const SizedBox(height: AppDimens.sm),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivilegeCheckbox(String keyName, String title, String subtitle, IconData icon) {
    final isChecked = _selectedPrivileges.contains(keyName);

    return CheckboxListTile(
      value: isChecked,
      contentPadding: EdgeInsets.zero,
      activeColor: const Color(0xFF24389C),
      secondary: Icon(icon, color: isChecked ? const Color(0xFF24389C) : AppColors.textSecondary, size: 20),
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      onChanged: (val) {
        setState(() {
          if (val == true) {
            _selectedPrivileges.add(keyName);
          } else {
            _selectedPrivileges.remove(keyName);
          }
        });
      },
    );
  }
}
