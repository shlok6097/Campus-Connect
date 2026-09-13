import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/publication_model.dart';
import '../../shared/buttons/primary_button.dart';
import '../../state/auth_controller.dart';
import '../../state/publish_controller.dart';

class CreatePublicationSheet extends StatefulWidget {
  final PublicationType initialType;

  const CreatePublicationSheet({super.key, required this.initialType});

  static Future<void> show(BuildContext context, {required PublicationType selectedType}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreatePublicationSheet(initialType: selectedType),
    );
  }

  @override
  State<CreatePublicationSheet> createState() => _CreatePublicationSheetState();
}

class _CreatePublicationSheetState extends State<CreatePublicationSheet> {
  final _formKey = GlobalKey<FormState>();
  late PublicationType _selectedType;
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _extraController = TextEditingController();

  // Poll options
  final List<TextEditingController> _pollOptionControllers = [
    TextEditingController(text: 'Option 1'),
    TextEditingController(text: 'Option 2'),
  ];

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _extraController.dispose();
    for (final c in _pollOptionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addPollOption() {
    if (_pollOptionControllers.length < 5) {
      setState(() {
        _pollOptionControllers.add(
          TextEditingController(text: 'Option ${_pollOptionControllers.length + 1}'),
        );
      });
    }
  }

  void _removePollOption(int index) {
    if (_pollOptionControllers.length > 2) {
      setState(() {
        _pollOptionControllers[index].dispose();
        _pollOptionControllers.removeAt(index);
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final user = AuthController.instance.currentUser;
    final clubName = user.clubName ?? 'Test club';

    final metadata = <String, dynamic>{};

    switch (_selectedType) {
      case PublicationType.poll:
        final options = _pollOptionControllers
            .map((c) => {
                  'label': c.text.trim().isNotEmpty ? c.text.trim() : 'Option',
                  'votes': 0,
                  'percent': 0,
                })
            .toList();
        metadata['options'] = options;
        metadata['total_votes'] = 0;
        break;
      case PublicationType.quiz:
        metadata['questions_count'] = int.tryParse(_extraController.text.trim()) ?? 5;
        metadata['difficulty'] = 'All Levels';
        metadata['participants'] = 0;
        break;
      case PublicationType.document:
      case PublicationType.report:
        metadata['file_type'] = 'PDF';
        metadata['file_size'] = _extraController.text.trim().isNotEmpty ? _extraController.text.trim() : '2.4 MB';
        break;
      case PublicationType.fact:
        metadata['category'] = _extraController.text.trim().isNotEmpty ? _extraController.text.trim() : 'General Tech';
        metadata['verified'] = true;
        break;
      case PublicationType.resource:
      case PublicationType.project:
        metadata['link_url'] = _extraController.text.trim().isNotEmpty ? _extraController.text.trim() : 'https://github.com';
        break;
      default:
        break;
    }

    final publication = PublicationModel(
      id: 'pub_${DateTime.now().millisecondsSinceEpoch}',
      clubId: user.clubId,
      clubName: clubName,
      type: _selectedType,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      metadata: metadata,
      authorName: user.name.isNotEmpty ? user.name : 'Club Leader',
      authorId: user.id,
      createdAt: DateTime.now(),
    );

    await PublishController.instance.publishContent(publication);

    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('${_selectedType.displayName} published successfully!'),
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
              // Drag Handle
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

              // Title & Type Switcher Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Publish ${_selectedType.displayName}',
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

              // Title Field
              Text(
                'Title',
                style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Enter ${_selectedType.displayName.toLowerCase()} title...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: AppDimens.md),

              // Content / Description Field
              Text(
                'Description / Content',
                style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _contentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Share full details, explanations, instructions...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter content' : null,
              ),
              const SizedBox(height: AppDimens.md),

              // Conditional Extra Fields based on Type
              if (_selectedType == PublicationType.poll) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Poll Options',
                      style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (_pollOptionControllers.length < 5)
                      TextButton.icon(
                        onPressed: _addPollOption,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Option'),
                      ),
                  ],
                ),
                ...List.generate(_pollOptionControllers.length, (idx) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _pollOptionControllers[idx],
                            decoration: InputDecoration(
                              hintText: 'Option ${idx + 1}',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                        if (_pollOptionControllers.length > 2)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.red, size: 20),
                            onPressed: () => _removePollOption(idx),
                          ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: AppDimens.md),
              ] else if (_selectedType == PublicationType.quiz) ...[
                Text(
                  'Number of Questions',
                  style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _extraController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'e.g. 10',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: AppDimens.md),
              ] else if (_selectedType == PublicationType.document || _selectedType == PublicationType.report) ...[
                Text(
                  'Attachment / File Size (Simulated)',
                  style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _extraController,
                  decoration: InputDecoration(
                    hintText: 'e.g. PDF • 4.2 MB',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: AppDimens.md),
              ] else if (_selectedType == PublicationType.resource || _selectedType == PublicationType.project) ...[
                Text(
                  'Resource / Project Link URL',
                  style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _extraController,
                  decoration: InputDecoration(
                    hintText: 'https://...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: AppDimens.md),
              ] else if (_selectedType == PublicationType.fact) ...[
                Text(
                  'Topic / Subcategory',
                  style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _extraController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Cybersecurity, AI, Quantum Computing',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: AppDimens.md),
              ],

              // Publish Button
              PrimaryButton(
                label: _isSubmitting ? 'Publishing...' : 'Publish to Club Feed',
                icon: Icons.send,
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
}
