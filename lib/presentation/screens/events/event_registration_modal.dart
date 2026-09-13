import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/event_model.dart';
import '../../shared/buttons/primary_button.dart';
import '../../shared/cards/payment_qr_card.dart';
import '../../shared/feedback/custom_bottom_sheet.dart';
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
      title: event.isPaid ? 'Registration & Payment' : 'Event Registration',
      subtitle: event.isPaid
          ? 'Entry Fee: ₹${event.entryFee.toStringAsFixed(0)} • Scan QR or pay via UPI'
          : 'Fill in your details to secure your spot for ${event.title}',
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
  final _paymentRefController = TextEditingController();
  bool _isSuccess = false;
  bool _isSubmitting = false;
  String _generatedRegId = '';

  @override
  void initState() {
    super.initState();
    // Initialize default values for dropdowns and multiple choice
    for (final field in widget.event.customFormFields) {
      if (field.options.isNotEmpty) {
        _customResponses[field.label] = field.options.first;
      }
    }
  }

  @override
  void dispose() {
    _paymentRefController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSubmitting = true);

    final user = AuthController.instance.currentUser;
    final isPaid = widget.event.isPaid;
    final paymentStatus = isPaid ? 'pending' : 'free';
    final paymentRef = isPaid ? _paymentRefController.text.trim() : null;

    final success = await EventController.instance.registerForEvent(
      event: widget.event,
      user: user,
      customResponses: _customResponses,
      paymentStatus: paymentStatus,
      paymentReference: paymentRef,
      amount: widget.event.entryFee,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      if (success) {
        _generatedRegId = 'REG-2026-${1000 + EventController.instance.allRegistrations.length}';
        _isSuccess = true;
      }
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
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, size: 56, color: AppColors.green),
          ),
          const SizedBox(height: AppDimens.md),
          Text(
            'Registration Confirmed! 🎉',
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.green,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimens.xs),
          Text(
            'You are registered for ${widget.event.title}. A confirmation has been recorded under your student account (${user.studentId}).',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimens.lg),
          Container(
            padding: const EdgeInsets.all(AppDimens.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Registration Pass ID:', style: AppTextStyles.labelMedium),
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
          if (widget.event.isPaid) ...[
            const SizedBox(height: AppDimens.md),
            Container(
              padding: const EdgeInsets.all(AppDimens.sm),
              decoration: BoxDecoration(
                color: AppColors.yellow.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.yellow.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 18, color: AppColors.yellow),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Payment Status: Pending Verification by Organizer',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF8F4700),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppDimens.xl),
          PrimaryButton(
            label: 'Done',
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
          // Student Profile Summary
          Container(
            padding: const EdgeInsets.all(AppDimens.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registrant Information',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      user.name,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      user.studentId,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${user.branch} • Sem ${user.semester}',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.lg),

          // Custom Questions from Form Builder
          if (widget.event.customFormFields.isNotEmpty) ...[
            Text(
              'Required Registration Details',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimens.sm),
            ...widget.event.customFormFields.map((field) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.md),
                child: _buildFormField(field),
              );
            }),
          ],

          // Payment Section for Paid Events
          if (widget.event.isPaid) ...[
            const SizedBox(height: AppDimens.sm),
            PaymentQRCard(
              upiId: widget.event.paymentUpiId ?? 'event@upi',
              amount: widget.event.entryFee,
              eventName: widget.event.title,
            ),
            const SizedBox(height: AppDimens.md),
            TextFormField(
              controller: _paymentRefController,
              decoration: const InputDecoration(
                labelText: 'UPI Transaction ID / UTR Number *',
                hintText: 'e.g., 423589123456 or UTR reference',
                prefixIcon: Icon(Icons.receipt_long, color: AppColors.blue),
              ),
              validator: (v) {
                if (widget.event.isPaid && (v == null || v.trim().isEmpty)) {
                  return 'Please enter transaction / UTR reference number';
                }
                return null;
              },
            ),
            const SizedBox(height: 4),
            Text(
              'After making the payment via your UPI app, enter the transaction reference ID above.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimens.md),
          ],

          const SizedBox(height: AppDimens.md),
          PrimaryButton(
            label: widget.event.isPaid
                ? 'Confirm & Submit (₹${widget.event.entryFee.toStringAsFixed(0)})'
                : 'Confirm Free Registration',
            backgroundColor: const Color(0xFF008744),
            isLoading: _isSubmitting,
            onPressed: _isSubmitting ? null : _handleSubmit,
          ),
          const SizedBox(height: AppDimens.md),
        ],
      ),
    );
  }

  Widget _buildFormField(CustomFormField field) {
    switch (field.type) {
      case QuestionType.dropdown:
        return DropdownButtonFormField<String>(
          initialValue: _customResponses[field.label] as String? ?? (field.options.isNotEmpty ? field.options.first : null),
          decoration: InputDecoration(
            labelText: '${field.label}${field.isRequired ? ' *' : ''}',
          ),
          items: field.options.map((opt) {
            return DropdownMenuItem(value: opt, child: Text(opt));
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => _customResponses[field.label] = val);
            }
          },
          validator: (v) {
            if (field.isRequired && (v == null || v.isEmpty)) {
              return 'Please select an option';
            }
            return null;
          },
        );

      case QuestionType.multipleChoice:
        final selectedVal = _customResponses[field.label] as String? ?? (field.options.isNotEmpty ? field.options.first : '');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${field.label}${field.isRequired ? ' *' : ''}',
              style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            ...field.options.map((opt) {
              return RadioListTile<String>(
                title: Text(opt, style: AppTextStyles.bodyMedium),
                value: opt,
                groupValue: selectedVal,
                dense: true,
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.blue,
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _customResponses[field.label] = v);
                  }
                },
              );
            }),
          ],
        );

      case QuestionType.checkbox:
        final selectedList = (_customResponses[field.label] as List<String>?) ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${field.label}${field.isRequired ? ' *' : ''}',
              style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            ...field.options.map((opt) {
              final isChecked = selectedList.contains(opt);
              return CheckboxListTile(
                title: Text(opt, style: AppTextStyles.bodyMedium),
                value: isChecked,
                dense: true,
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.blue,
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      selectedList.add(opt);
                    } else {
                      selectedList.remove(opt);
                    }
                    _customResponses[field.label] = selectedList;
                  });
                },
              );
            }),
          ],
        );

      case QuestionType.multiline:
        return TextFormField(
          maxLines: 3,
          decoration: InputDecoration(
            labelText: '${field.label}${field.isRequired ? ' *' : ''}',
            hintText: 'Enter details...',
          ),
          onSaved: (val) => _customResponses[field.label] = val?.trim() ?? '',
          validator: (v) {
            if (field.isRequired && (v == null || v.trim().isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
        );

      case QuestionType.text:
        return TextFormField(
          decoration: InputDecoration(
            labelText: '${field.label}${field.isRequired ? ' *' : ''}',
            hintText: 'Enter answer',
          ),
          onSaved: (val) => _customResponses[field.label] = val?.trim() ?? '',
          validator: (v) {
            if (field.isRequired && (v == null || v.trim().isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
        );
    }
  }
}
