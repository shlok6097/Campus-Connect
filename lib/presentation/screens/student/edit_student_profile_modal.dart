import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/user_model.dart';
import '../../shared/buttons/primary_button.dart';
import '../../state/auth_controller.dart';

class EditStudentProfileModal extends StatefulWidget {
  final UserModel user;

  const EditStudentProfileModal({super.key, required this.user});

  static Future<void> show(BuildContext context, {required UserModel user}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditStudentProfileModal(user: user),
    );
  }

  @override
  State<EditStudentProfileModal> createState() => _EditStudentProfileModalState();
}

class _EditStudentProfileModalState extends State<EditStudentProfileModal> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _studentIdController;
  late TextEditingController _branchController;
  late TextEditingController _bioController;
  late TextEditingController _avatarUrlController;
  final TextEditingController _skillInputController = TextEditingController();
  final TextEditingController _lookingForInputController = TextEditingController();

  Uint8List? _selectedImageBytes;
  String? _selectedImageFileName;
  bool _isPickingImage = false;

  late int _semester;
  late int _endingYear;
  late bool _isAvailableForTeams;
  late List<String> _skills;
  late List<String> _lookingFor;

  bool _isSubmitting = false;

  final List<String> _branches = [
    'Computer Science & Engineering',
    'Information Science & Engineering',
    'Artificial Intelligence & ML',
    'Electronics & Communication',
    'Electrical & Electronics',
    'Mechanical Engineering',
    'Civil Engineering',
    'Data Science',
    'Cyber Security',
  ];

  final List<String> _suggestedSkills = [
    'Flutter',
    'Python',
    'Dart',
    'React',
    'Node.js',
    'Java',
    'C++',
    'Machine Learning',
    'UI/UX Design',
    'Cybersecurity',
    'SQL',
    'Cloud / AWS',
  ];

  final List<String> _suggestedInterests = [
    'Hackathons',
    'AI/ML Projects',
    'Open Source',
    'App Development',
    'Web Development',
    'Robotics & IoT',
    'Competitive Coding',
    'Research',
    'Internships',
  ];

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _nameController = TextEditingController(text: u.name);
    _phoneController = TextEditingController(text: u.phone);
    _studentIdController = TextEditingController(text: u.studentId);
    _branchController = TextEditingController(
      text: u.branch.isNotEmpty ? u.branch : _branches.first,
    );
    _bioController = TextEditingController(text: u.bio);
    _avatarUrlController = TextEditingController(text: u.avatarUrl);

    _semester = u.semester > 0 ? u.semester : 1;
    _endingYear = u.endingYear > 0 ? u.endingYear : (DateTime.now().year + 2);
    _isAvailableForTeams = u.isAvailableForTeams;
    _skills = List<String>.from(u.skills);
    _lookingFor = List<String>.from(u.lookingFor);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _studentIdController.dispose();
    _branchController.dispose();
    _bioController.dispose();
    _avatarUrlController.dispose();
    _skillInputController.dispose();
    _lookingForInputController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    setState(() => _isPickingImage = true);
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageFileName = pickedFile.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open gallery: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  void _clearSelectedImage() {
    setState(() {
      _selectedImageBytes = null;
      _selectedImageFileName = null;
      _avatarUrlController.clear();
    });
  }

  void _addSkill(String skill) {
    final trimmed = skill.trim();
    if (trimmed.isNotEmpty && !_skills.contains(trimmed)) {
      setState(() {
        _skills.add(trimmed);
        _skillInputController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  void _addInterest(String item) {
    final trimmed = item.trim();
    if (trimmed.isNotEmpty && !_lookingFor.contains(trimmed)) {
      setState(() {
        _lookingFor.add(trimmed);
        _lookingForInputController.clear();
      });
    }
  }

  void _removeInterest(String item) {
    setState(() {
      _lookingFor.remove(item);
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    String finalAvatarUrl = _avatarUrlController.text.trim();

    // 1. If an image was picked from gallery, upload to Supabase Storage
    if (_selectedImageBytes != null) {
      final userId = AuthController.instance.currentUser.id;
      final fileName = 'avatar_${userId.isNotEmpty ? userId : "usr"}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      if (SupabaseService.instance.isInitialized) {
        try {
          final client = SupabaseService.instance.client;
          await client.storage.from('avatars').uploadBinary(
            fileName,
            _selectedImageBytes!,
          );
          finalAvatarUrl = client.storage.from('avatars').getPublicUrl(fileName);
        } catch (storageErr) {
          debugPrint('Storage upload fallback to base64: $storageErr');
          finalAvatarUrl = 'data:image/jpeg;base64,${base64Encode(_selectedImageBytes!)}';
        }
      } else {
        finalAvatarUrl = 'data:image/jpeg;base64,${base64Encode(_selectedImageBytes!)}';
      }
    }

    // 2. Save profile data to database & AuthController
    final success = await AuthController.instance.updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      studentId: _studentIdController.text.trim(),
      branch: _branchController.text.trim(),
      semester: _semester,
      endingYear: _endingYear,
      bio: _bioController.text.trim(),
      avatarUrl: finalAvatarUrl,
      skills: _skills,
      lookingFor: _lookingFor,
      isAvailableForTeams: _isAvailableForTeams,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully! ✨'),
            backgroundColor: AppColors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AuthController.instance.errorMessage ?? 'Failed to update profile.',
            ),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusXl)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header handle
          const SizedBox(height: AppDimens.sm),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title Bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.lg,
              vertical: AppDimens.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.edit_note, color: AppColors.blue, size: 26),
                    const SizedBox(width: 8),
                    Text(
                      'Edit Student Profile',
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.outline),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.outlineVariant),

          // Form Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar & Gallery Pick Section
                    _buildAvatarSection(),
                    const SizedBox(height: AppDimens.lg),

                    // Full Name
                    _buildTextField(
                      label: 'Full Name *',
                      controller: _nameController,
                      icon: Icons.person_outline,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Enter your full name' : null,
                    ),
                    const SizedBox(height: AppDimens.md),

                    // Student ID / USN & Phone
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'USN / Student ID',
                            controller: _studentIdController,
                            icon: Icons.badge_outlined,
                            hint: 'e.g. 1UV21CS045',
                          ),
                        ),
                        const SizedBox(width: AppDimens.md),
                        Expanded(
                          child: _buildTextField(
                            label: 'Phone Number',
                            controller: _phoneController,
                            icon: Icons.phone_outlined,
                            hint: '+91 9876543210',
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.md),

                    // Branch Dropdown
                    Text('Branch / Department *', style: AppTextStyles.labelMedium),
                    const SizedBox(height: AppDimens.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.outlineVariant),
                        borderRadius: AppDimens.borderMd,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _branches.contains(_branchController.text)
                              ? _branchController.text
                              : null,
                          hint: Text(_branchController.text.isNotEmpty
                              ? _branchController.text
                              : 'Select Branch'),
                          isExpanded: true,
                          items: _branches.map((b) {
                            return DropdownMenuItem(value: b, child: Text(b));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _branchController.text = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimens.md),

                    // Semester & Graduation Year
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Current Semester', style: AppTextStyles.labelMedium),
                              const SizedBox(height: AppDimens.xs),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.outlineVariant),
                                  borderRadius: AppDimens.borderMd,
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: _semester,
                                    isExpanded: true,
                                    items: List.generate(8, (i) => i + 1).map((s) {
                                      return DropdownMenuItem(
                                        value: s,
                                        child: Text('Semester $s'),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) setState(() => _semester = val);
                                    },
                                  ),
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
                              Text('Graduation Year', style: AppTextStyles.labelMedium),
                              const SizedBox(height: AppDimens.xs),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.outlineVariant),
                                  borderRadius: AppDimens.borderMd,
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: _endingYear,
                                    isExpanded: true,
                                    items: List.generate(8, (i) => DateTime.now().year - 2 + i)
                                        .map((yr) {
                                      return DropdownMenuItem(
                                        value: yr,
                                        child: Text('$yr Batch'),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) setState(() => _endingYear = val);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.md),

                    // Bio / About Me
                    _buildTextField(
                      label: 'Bio / About Me',
                      controller: _bioController,
                      icon: Icons.notes,
                      hint: 'Tell classmates and clubs about your passions, tech interests...',
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppDimens.lg),

                    // Skills Tags
                    _buildTagInputSection(
                      title: 'Technical Skills & Tools',
                      tags: _skills,
                      inputController: _skillInputController,
                      onAdd: _addSkill,
                      onRemove: _removeSkill,
                      suggestions: _suggestedSkills,
                      hint: 'e.g. Flutter, Dart, PyTorch...',
                    ),
                    const SizedBox(height: AppDimens.lg),

                    // Looking For / Interests
                    _buildTagInputSection(
                      title: 'Looking For / Interests',
                      tags: _lookingFor,
                      inputController: _lookingForInputController,
                      onAdd: _addInterest,
                      onRemove: _removeInterest,
                      suggestions: _suggestedInterests,
                      hint: 'e.g. Hackathons, AI Projects...',
                    ),
                    const SizedBox(height: AppDimens.lg),

                    // Available for Teams Switch
                    Container(
                      padding: const EdgeInsets.all(AppDimens.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: AppDimens.borderMd,
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isAvailableForTeams
                                ? Icons.check_circle_outline
                                : Icons.highlight_off,
                            color: _isAvailableForTeams
                                ? AppColors.green
                                : AppColors.outline,
                          ),
                          const SizedBox(width: AppDimens.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Available for Teams & Projects',
                                  style: AppTextStyles.titleLarge.copyWith(fontSize: 14),
                                ),
                                Text(
                                  'Allow other students to invite you to hackathon teams.',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isAvailableForTeams,
                            activeColor: AppColors.green,
                            onChanged: (val) => setState(() => _isAvailableForTeams = val),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimens.xl),

                    // Save Button
                    PrimaryButton(
                      label: _isSubmitting ? 'Saving Changes...' : 'Save Profile Changes',
                      icon: Icons.check,
                      backgroundColor: AppColors.blue,
                      onPressed: _isSubmitting ? null : _saveProfile,
                    ),
                    const SizedBox(height: AppDimens.md),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    final avatarUrl = _avatarUrlController.text.trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar Circle with Camera Badge
        GestureDetector(
          onTap: _pickImageFromGallery,
          child: Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.blueLight,
                  border: Border.all(color: AppColors.blue, width: 2.5),
                ),
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                child: _selectedImageBytes != null
                    ? Image.memory(
                        _selectedImageBytes!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                    : avatarUrl.isNotEmpty
                        ? (avatarUrl.startsWith('data:image')
                            ? Image.memory(
                                base64Decode(avatarUrl.split(',').last),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: AppColors.blue,
                                ),
                              )
                            : Image.network(
                                avatarUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: AppColors.blue,
                                ),
                              ))
                        : Text(
                            _nameController.text.isNotEmpty
                                ? _nameController.text[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.blue,
                            ),
                          ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 14,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimens.md),

        // Action Buttons
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profile Photo', style: AppTextStyles.labelMedium),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  OutlinedButton.icon(
                    onPressed: _isPickingImage ? null : _pickImageFromGallery,
                    icon: const Icon(Icons.photo_library, size: 16, color: AppColors.blue),
                    label: Text(
                      _selectedImageBytes != null ? 'Change Photo' : 'Upload from Gallery',
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.blue),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.blue),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: AppDimens.borderMd),
                    ),
                  ),
                  if (_selectedImageBytes != null || avatarUrl.isNotEmpty)
                    TextButton.icon(
                      onPressed: _clearSelectedImage,
                      icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.red),
                      label: Text(
                        'Remove',
                        style: AppTextStyles.labelMedium.copyWith(color: AppColors.red),
                      ),
                    ),
                ],
              ),
              if (_selectedImageFileName != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Selected: $_selectedImageFileName',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColors.greenDark,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        const SizedBox(height: AppDimens.xs),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.outline),
            prefixIcon: icon != null ? Icon(icon, size: 18, color: AppColors.outline) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: AppDimens.borderMd,
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagInputSection({
    required String title,
    required List<String> tags,
    required TextEditingController inputController,
    required Function(String) onAdd,
    required Function(String) onRemove,
    required List<String> suggestions,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.labelMedium),
        const SizedBox(height: AppDimens.xs),

        // Active Chips
        if (tags.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tags.map((tag) {
              return Chip(
                label: Text(tag, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                deleteIcon: const Icon(Icons.close, size: 14),
                onDeleted: () => onRemove(tag),
                backgroundColor: AppColors.blueLight,
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              );
            }).toList(),
          ),
          const SizedBox(height: AppDimens.sm),
        ],

        // Input row
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: inputController,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.outline),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: AppDimens.borderMd),
                ),
                onFieldSubmitted: (val) => onAdd(val),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              style: IconButton.styleFrom(backgroundColor: AppColors.blue),
              icon: const Icon(Icons.add, color: AppColors.white, size: 20),
              onPressed: () => onAdd(inputController.text),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.sm),

        // Quick suggestions
        Text('Quick suggestions:', style: AppTextStyles.bodySmall.copyWith(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: suggestions.where((s) => !tags.contains(s)).take(6).map((s) {
            return ActionChip(
              label: Text('+ $s', style: const TextStyle(fontSize: 11)),
              onPressed: () => onAdd(s),
              backgroundColor: AppColors.surfaceContainerLow,
              side: const BorderSide(color: AppColors.outlineVariant),
              padding: const EdgeInsets.symmetric(horizontal: 2),
            );
          }).toList(),
        ),
      ],
    );
  }
}
