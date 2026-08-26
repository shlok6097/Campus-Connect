import 'package:flutter/material.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/event_model.dart';
import '../../shared/buttons/primary_button.dart';
import '../../shared/buttons/secondary_button.dart';
import '../../shared/cards/bento_card.dart';
import '../../shared/inputs/app_dropdown.dart';
import '../../shared/inputs/app_text_field.dart';
import '../../state/event_controller.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _venueController = TextEditingController(
    text: 'Main Campus Auditorium',
  );
  final _capacityController = TextEditingController(text: '150');
  final _feeController = TextEditingController(text: '0');

  EventCategory _selectedCategory = EventCategory.workshop;
  final DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  final DateTime _endDate = DateTime.now().add(const Duration(days: 7));

  final List<CustomFormField> _customQuestions = [
    const CustomFormField(
      id: 'q1',
      label: 'T-Shirt Size',
      type: QuestionType.dropdown,
      options: ['S', 'M', 'L', 'XL', 'XXL'],
    ),
    const CustomFormField(
      id: 'q2',
      label: 'GitHub Profile Link',
      type: QuestionType.text,
      isRequired: true,
    ),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _venueController.dispose();
    _capacityController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  void _addQuestion() {
    final labelController = TextEditingController();
    QuestionType selectedType = QuestionType.text;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Registration Question'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelController,
                decoration: const InputDecoration(
                  labelText: 'Question Label (e.g. Portfolio Link)',
                ),
              ),
              const SizedBox(height: AppDimens.md),
              DropdownButtonFormField<QuestionType>(
                initialValue: selectedType,
                decoration: const InputDecoration(labelText: 'Question Type'),
                items: const [
                  DropdownMenuItem(
                    value: QuestionType.text,
                    child: Text('Short Text'),
                  ),
                  DropdownMenuItem(
                    value: QuestionType.multiline,
                    child: Text('Paragraph'),
                  ),
                  DropdownMenuItem(
                    value: QuestionType.dropdown,
                    child: Text('Dropdown (T-Shirt, Diet)'),
                  ),
                ],
                onChanged: (val) => setDialogState(
                  () => selectedType = val ?? QuestionType.text,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (labelController.text.isNotEmpty) {
                  setState(() {
                    _customQuestions.add(
                      CustomFormField(
                        id: 'q_${DateTime.now().millisecondsSinceEpoch}',
                        label: labelController.text,
                        type: selectedType,
                        options: selectedType == QuestionType.dropdown
                            ? ['Option A', 'Option B']
                            : const [],
                      ),
                    );
                  });
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Add Field'),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePublish() {
    if (!_formKey.currentState!.validate()) return;

    final newEvent = EventModel(
      id: 'evt_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text,
      description: _descController.text,
      category: _selectedCategory,
      bannerUrl: AssetConstants.workshopBanner,
      startDate: _startDate,
      endDate: _endDate,
      timeString: '9:00 AM – 5:00 PM',
      venue: _venueController.text,
      organizerName: 'Coding Club & GDG UVCE',
      maxParticipants: int.tryParse(_capacityController.text) ?? 100,
      entryFee: double.tryParse(_feeController.text) ?? 0.0,
      isPublished: true,
      customFormFields: _customQuestions,
    );

    EventController.instance.createEvent(newEvent);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event published successfully! 🎉')),
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
          'Create New Event',
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
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppDimens.md),
                      AppTextField(
                        label: 'Event Title',
                        hint: 'e.g. AI Masterclass 2026',
                        controller: _titleController,
                        isRequired: true,
                        validator: (val) => val == null || val.isEmpty
                            ? 'Please enter event title'
                            : null,
                      ),
                      const SizedBox(height: AppDimens.md),
                      AppTextField(
                        label: 'Description',
                        hint:
                            'Detailed overview of the event, itinerary, and agenda...',
                        controller: _descController,
                        maxLines: 3,
                        isRequired: true,
                        validator: (val) => val == null || val.isEmpty
                            ? 'Please enter description'
                            : null,
                      ),
                      const SizedBox(height: AppDimens.md),
                      AppDropdown<EventCategory>(
                        label: 'Category',
                        hint: 'Select Category',
                        value: _selectedCategory,
                        items: const [
                          DropdownMenuItem(
                            value: EventCategory.workshop,
                            child: Text('Workshop'),
                          ),
                          DropdownMenuItem(
                            value: EventCategory.hackathon,
                            child: Text('Hackathon'),
                          ),
                          DropdownMenuItem(
                            value: EventCategory.technical,
                            child: Text('Technical Competition'),
                          ),
                          DropdownMenuItem(
                            value: EventCategory.cultural,
                            child: Text('Cultural'),
                          ),
                        ],
                        onChanged: (val) => setState(
                          () => _selectedCategory = val ?? _selectedCategory,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.lg),

                // 2. Schedule & Venue
                BentoCard(
                  padding: const EdgeInsets.all(AppDimens.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Schedule & Logistics',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppDimens.md),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Venue',
                              hint: 'Hall / Lab name',
                              controller: _venueController,
                              isRequired: true,
                            ),
                          ),
                          const SizedBox(width: AppDimens.sm),
                          Expanded(
                            child: AppTextField(
                              label: 'Max Capacity',
                              hint: '100',
                              controller: _capacityController,
                              keyboardType: TextInputType.number,
                              isRequired: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimens.md),
                      AppTextField(
                        label: 'Entry Fee (₹)',
                        hint: '0 for Free entry',
                        controller: _feeController,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.lg),

                // 3. Custom Registration Form Builder
                BentoCard(
                  padding: const EdgeInsets.all(AppDimens.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Registration Form Builder',
                            style: AppTextStyles.titleLarge.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: _addQuestion,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Field'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimens.xs),
                      Text(
                        'Customize attendee questions on the registration modal.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimens.md),
                      ..._customQuestions.map((q) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppDimens.sm),
                          child: Container(
                            padding: const EdgeInsets.all(AppDimens.md),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: AppDimens.borderMd,
                              border: Border.all(
                                color: AppColors.outlineVariant,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.drag_indicator,
                                  color: AppColors.outline,
                                ),
                                const SizedBox(width: AppDimens.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        q.label,
                                        style: AppTextStyles.titleLarge
                                            .copyWith(fontSize: 15),
                                      ),
                                      Text(
                                        'Type: ${q.type.name} • ${q.isRequired ? "Required" : "Optional"}',
                                        style: AppTextStyles.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppColors.red,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() => _customQuestions.remove(q));
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.xl),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: 'Save Draft',
                        color: AppColors.textSecondary,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: AppDimens.md),
                    Expanded(
                      child: PrimaryButton(
                        label: 'Publish Event',
                        backgroundColor: AppColors.green,
                        onPressed: _handlePublish,
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
