import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/event_model.dart';
import '../../shared/buttons/primary_button.dart';
import '../../shared/cards/bento_card.dart';
import '../../shared/feedback/custom_bottom_sheet.dart';
import '../../shared/inputs/app_dropdown.dart';
import '../../shared/inputs/app_text_field.dart';
import '../../state/auth_controller.dart';
import '../../state/event_controller.dart';

class EventRegistrationModal {
  EventRegistrationModal._();

  static void show({
    required BuildContext context,
    required EventModel event,
  }) {
    CustomBottomSheet.show(
      context: context,
      title: 'Register for ${event.title}',
      subtitle: 'Complete the form below to secure your spot',
      content: _RegistrationFormContent(event: event),
    );
  }
}

class _RegistrationFormContent extends StatefulWidget {
  final EventModel event;

  const _RegistrationFormContent({required this.event});

  @override
  State<_RegistrationFormContent> createState() => _RegistrationFormContentState();
}

class _RegistrationFormContentState extends State<_RegistrationFormContent> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _customResponses = {};
  bool _isSuccess = false;
  String _generatedRegId = '';

  @override
  void initState() {
    super.initState();
    // Default answers for dropdowns
    for (final field in widget.event.customFormFields) {
      if (field.type == QuestionType.dropdown && field.options.isNotEmpty) {
        _customResponses[field.label] = field.options.first;
      }
    }
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final user = AuthController.instance.currentUser;
    EventController.instance.registerForEvent(
      event: widget.event,
      user: user,
      customResponses: _customResponses,
    );

    setState(() {
      _generatedRegId = 'REG-2026-${1000 + EventController.instance.allRegistrations.length}';
      _isSuccess = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthController.instance.currentUser;

    if (_isSuccess) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimens.lg),
            decoration: const BoxDecoration(
              color: AppColors.greenLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, size: 56, color: AppColors.green),
          ),
          const SizedBox(height: AppDimens.md),
          Text(
            'Registration Confirmed! 🎉',
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.greenDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimens.xs),
          Text(
            'You are registered for ${widget.event.title}. A confirmation email has been sent to ${user.email}.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimens.lg),
          BentoCard(
            backgroundColor: AppColors.surfaceContainerLow,
            padding: const EdgeInsets.all(AppDimens.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pass ID:', style: AppTextStyles.labelMedium),
                Text(
                  _generatedRegId,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.blue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.xl),
          PrimaryButton(
            label: 'Done',
            backgroundColor: AppColors.blue,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pre-filled student info
          BentoCard(
            backgroundColor: AppColors.surfaceContainerLow,
            padding: const EdgeInsets.all(AppDimens.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student Information',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.blue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimens.sm),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: AppColors.outline),
                    const SizedBox(width: 6),
                    Text('${user.name} (${user.studentId})', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.school, size: 16, color: AppColors.outline),
                    const SizedBox(width: 6),
                    Text('${user.branch} • Semester ${user.semester}', style: AppTextStyles.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.lg),

          // Custom Questions
          if (widget.event.customFormFields.isNotEmpty) ...[
            Text(
              'Event Specific Questions',
              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppDimens.md),
            ...widget.event.customFormFields.map((field) {
              if (field.type == QuestionType.dropdown) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.md),
                  child: AppDropdown<String>(
                    label: field.label,
                    hint: 'Select option',
                    value: _customResponses[field.label] as String?,
                    isRequired: field.isRequired,
                    items: field.options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
                    onChanged: (val) => setState(() => _customResponses[field.label] = val),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.md),
                child: AppTextField(
                  label: field.label,
                  hint: 'Your answer...',
                  isRequired: field.isRequired,
                  validator: field.isRequired ? (val) => val == null || val.isEmpty ? 'Required' : null : null,
                  onChanged: (val) => _customResponses[field.label] = val,
                ),
              );
            }),
          ],

          const SizedBox(height: AppDimens.lg),
          PrimaryButton(
            label: 'Confirm Registration',
            backgroundColor: AppColors.green,
            onPressed: _handleSubmit,
          ),
        ],
      ),
    );
  }
}
