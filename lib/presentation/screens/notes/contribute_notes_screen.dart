import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/note_model.dart';
import '../../shared/buttons/primary_button.dart';
import '../../shared/cards/bento_card.dart';
import '../../shared/inputs/app_dropdown.dart';
import '../../shared/inputs/app_text_field.dart';
import '../../state/auth_controller.dart';
import '../../state/note_controller.dart';

class ContributeNotesScreen extends StatefulWidget {
  const ContributeNotesScreen({super.key});

  @override
  State<ContributeNotesScreen> createState() => _ContributeNotesScreenState();
}

class _ContributeNotesScreenState extends State<ContributeNotesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _topicsController = TextEditingController();

  NoteSubject _selectedSubject = NoteSubject.dsa;
  String _selectedSemester = '5th Semester';
  String? _attachedFileName;
  final Set<String> _selectedTags = {'Lecture Notes'};

  final List<String> _availableTags = ['Midterm', 'Finals', 'Cheat Sheet', 'Lecture Notes', 'Lab Manual'];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _topicsController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    if (_attachedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or upload a note PDF file')),
      );
      return;
    }

    final user = AuthController.instance.currentUser;
    final newNote = NoteModel(
      id: 'note_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text,
      description: _descController.text,
      subject: _selectedSubject,
      authorName: user.name,
      authorAvatar: user.avatarUrl,
      course: '${user.branch} • $_selectedSemester',
      uploadDate: 'Just now',
      rating: 5.0,
      downloadCount: 1,
      fileFormat: 'PDF',
      fileSize: '3.2 MB',
      pageCount: 12,
      topicsCovered: _topicsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList(),
      tags: _selectedTags.toList(),
    );

    NoteController.instance.contributeNote(newNote);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notes uploaded successfully! +50 points earned 🎉')),
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
          'Contribute Notes',
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
                // Note Details Card
                BentoCard(
                  padding: const EdgeInsets.all(AppDimens.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Note Details',
                        style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppDimens.md),
                      AppTextField(
                        label: 'Note Title',
                        hint: 'e.g., Intro to Data Structures Midterm Review',
                        controller: _titleController,
                        isRequired: true,
                        validator: (val) => val == null || val.isEmpty ? 'Please enter a title' : null,
                      ),
                      const SizedBox(height: AppDimens.md),
                      Row(
                        children: [
                          Expanded(
                            child: AppDropdown<NoteSubject>(
                              label: 'Subject',
                              hint: 'Select Subject',
                              value: _selectedSubject,
                              isRequired: true,
                              items: const [
                                DropdownMenuItem(value: NoteSubject.dsa, child: Text('DSA')),
                                DropdownMenuItem(value: NoteSubject.os, child: Text('Operating Systems')),
                                DropdownMenuItem(value: NoteSubject.dbms, child: Text('DBMS')),
                                DropdownMenuItem(value: NoteSubject.cn, child: Text('Computer Networks')),
                                DropdownMenuItem(value: NoteSubject.ai, child: Text('AI / ML')),
                              ],
                              onChanged: (val) => setState(() => _selectedSubject = val ?? _selectedSubject),
                            ),
                          ),
                          const SizedBox(width: AppDimens.sm),
                          Expanded(
                            child: AppDropdown<String>(
                              label: 'Semester',
                              hint: 'Select Semester',
                              value: _selectedSemester,
                              isRequired: true,
                              items: const [
                                DropdownMenuItem(value: '1st Semester', child: Text('1st Sem')),
                                DropdownMenuItem(value: '2nd Semester', child: Text('2nd Sem')),
                                DropdownMenuItem(value: '3rd Semester', child: Text('3rd Sem')),
                                DropdownMenuItem(value: '4th Semester', child: Text('4th Sem')),
                                DropdownMenuItem(value: '5th Semester', child: Text('5th Sem')),
                                DropdownMenuItem(value: '6th Semester', child: Text('6th Sem')),
                                DropdownMenuItem(value: '7th Semester', child: Text('7th Sem')),
                                DropdownMenuItem(value: '8th Semester', child: Text('8th Sem')),
                              ],
                              onChanged: (val) => setState(() => _selectedSemester = val ?? _selectedSemester),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimens.md),
                      AppTextField(
                        label: 'Description',
                        hint: 'Briefly describe what these notes cover...',
                        controller: _descController,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.lg),

                // File Upload Card
                BentoCard(
                  padding: const EdgeInsets.all(AppDimens.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload Files *',
                        style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppDimens.md),
                      GestureDetector(
                        onTap: () {
                          setState(() => _attachedFileName = 'DSA_Trees_Comprehensive_Notes.pdf');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(AppDimens.xl),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: AppDimens.borderLg,
                            border: Border.all(
                              color: _attachedFileName != null ? AppColors.green : AppColors.outlineVariant,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  _attachedFileName != null ? Icons.check_circle : Icons.cloud_upload_outlined,
                                  size: 44,
                                  color: _attachedFileName != null ? AppColors.green : AppColors.blue,
                                ),
                                const SizedBox(height: AppDimens.sm),
                                Text(
                                  _attachedFileName != null ? _attachedFileName! : 'Tap to select or upload PDF notes',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: _attachedFileName != null ? AppColors.greenDark : AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Supports PDF, Documents (Max 50MB)',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.lg),

                // Metadata (Topics & Tags)
                BentoCard(
                  padding: const EdgeInsets.all(AppDimens.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Metadata & Tags',
                        style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppDimens.md),
                      AppTextField(
                        label: 'Topics Covered',
                        hint: 'e.g., Binary Trees, BST, AVL Rotations',
                        controller: _topicsController,
                      ),
                      const SizedBox(height: AppDimens.md),
                      Text('Optional Tags', style: AppTextStyles.labelMedium),
                      const SizedBox(height: AppDimens.xs),
                      Wrap(
                        spacing: 8,
                        children: _availableTags.map((tag) {
                          final isSelected = _selectedTags.contains(tag);
                          return FilterChip(
                            label: Text(tag),
                            selected: isSelected,
                            selectedColor: AppColors.blueContainer,
                            checkmarkColor: AppColors.white,
                            labelStyle: TextStyle(color: isSelected ? AppColors.white : AppColors.textPrimary),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedTags.add(tag);
                                } else {
                                  _selectedTags.remove(tag);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.xl),

                // Submit Button
                PrimaryButton(
                  label: 'Submit Contribution (+50 Pts)',
                  icon: Icons.publish,
                  backgroundColor: AppColors.green,
                  onPressed: _handleSubmit,
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
