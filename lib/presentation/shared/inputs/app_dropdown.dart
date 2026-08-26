import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';

class AppDropdown<T> extends StatelessWidget {
  final String? label;
  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final bool isRequired;
  final String? Function(T?)? validator;

  const AppDropdown({
    super.key,
    this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isRequired = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Row(
            children: [
              Text(
                label!,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isRequired)
                Text(
                  ' *',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.red,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimens.xs + 2),
        ],
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          style: AppTextStyles.bodyMedium,
          icon: const Icon(Icons.expand_more, color: AppColors.outline),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
