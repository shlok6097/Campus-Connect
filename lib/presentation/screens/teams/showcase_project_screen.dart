import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/team_model.dart';
import '../../shared/buttons/primary_button.dart';
import '../../shared/buttons/secondary_button.dart';
import '../../shared/cards/bento_card.dart';
import '../../shared/chips/app_chips.dart';
import '../../shared/inputs/app_dropdown.dart';
import '../../shared/inputs/app_text_field.dart';
import '../../state/team_controller.dart';

class ShowcaseProjectScreen extends StatefulWidget {
  const ShowcaseProjectScreen({super.key});

  @override
  State<ShowcaseProjectScreen> createState() => _ShowcaseProjectScreenState();
}

class _ShowcaseProjectScreenState extends State<ShowcaseProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _problemController = TextEditingController();
  final _solutionController = TextEditingController();

  String _selectedCategory = 'AI / ML';
  String _selectedStage = 'Development';
  final List<String> _selectedTech = ['Flutter', 'Firebase'];
  final List<String> _selectedRoles = ['UI/UX Designer'];

  final List<String> _categories = ['Web App', 'Mobile App', 'AI / ML', 'Hardware / IoT', 'Cybersecurity'];
  final List<String> _stages = ['Idea Phase', 'Prototyping', 'Development', 'MVP Ready', 'Live / Production'];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _problemController.dispose();
    _solutionController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final newProject = ProjectModel(
      id: 'proj_${DateTime.now().millisecondsSinceEpoch}',
      title: _nameController.text,
      problem: _problemController.text.isNotEmpty ? _problemController.text : _descController.text,
      solution: _solutionController.text.isNotEmpty ? _solutionController.text : _descController.text,
      category: _selectedCategory,
      techStack: _selectedTech,
      lookingForRoles: _selectedRoles,
      isPublic: true,
    );

    TeamController.instance.updateProject('team_nova', newProject);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Project published to campus showcase! 🎉')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: Text(
          'Showcase Your Project',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.blue,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.marginMobile),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Basic Details
                BentoCard(
                  padding: const EdgeInsets.all(AppDimens.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Basic Details',
                        style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppDimens.md),
                      AppTextField(
                        label: 'Project Name',
                        hint: 'e.g., Campus Connect App',
                        controller: _nameController,
                        isRequired: true,
                        validator: (val) => val == null || val.isEmpty ? 'Please enter project name' : null,
                      ),
                      const SizedBox(height: AppDimens.md),
                      AppTextField(
                        label: 'Short Description',
                        hint: 'A brief overview of what your project achieves...',
                        controller: _descController,
                        maxLines: 3,
                        isRequired: true,
                        validator: (val) => val == null || val.isEmpty ? 'Please enter a description' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.lg),

                // 2. Project Deep Dive
                BentoCard(
                  padding: const EdgeInsets.all(AppDimens.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Problem & Solution',
                        style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppDimens.md),
                      AppTextField(
                        label: "Problem You're Solving",
                        hint: 'What pain point does this address on campus?',
                        controller: _problemController,
                        maxLines: 2,
                      ),
                      const SizedBox(height: AppDimens.md),
                      AppTextField(
                        label: 'What Are You Building?',
                        hint: 'Describe the technical solution in detail...',
                        controller: _solutionController,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.lg),

                // 3. Tech & Team Details
                BentoCard(
                  padding: const EdgeInsets.all(AppDimens.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tech & Team',
                        style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppDimens.md),
                      AppDropdown<String>(
                        label: 'Category',
                        hint: 'Select Category',
                        value: _selectedCategory,
                        items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (val) => setState(() => _selectedCategory = val ?? _selectedCategory),
                      ),
                      const SizedBox(height: AppDimens.md),
                      AppDropdown<String>(
                        label: 'Current Stage',
                        hint: 'Select Stage',
                        value: _selectedStage,
                        items: _stages.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) => setState(() => _selectedStage = val ?? _selectedStage),
                      ),
                      const SizedBox(height: AppDimens.md),
                      Text('Tech Stack', style: AppTextStyles.labelMedium),
                      const SizedBox(height: AppDimens.xs),
                      Wrap(
                        spacing: 6,
                        children: [
                          ..._selectedTech.map((t) => SkillChip(
                                label: t,
                                onDeleted: () => setState(() => _selectedTech.remove(t)),
                              )),
                          ActionChip(
                            label: const Text('+ Add Tech'),
                            onPressed: () {
                              setState(() => _selectedTech.add('Python'));
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.lg),

                // 4. Media Upload Box
                BentoCard(
                  padding: const EdgeInsets.all(AppDimens.xl),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.cloud_upload_outlined, size: 48, color: AppColors.blue),
                        const SizedBox(height: AppDimens.sm),
                        Text(
                          'Upload Project Image or Mockup',
                          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'PNG, JPG up to 5MB',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.xl),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: 'Cancel',
                        color: AppColors.textSecondary,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: AppDimens.md),
                    Expanded(
                      child: PrimaryButton(
                        label: 'Publish Project',
                        backgroundColor: AppColors.green,
                        onPressed: _handleSubmit,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
