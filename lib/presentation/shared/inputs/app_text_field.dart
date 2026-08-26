import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? initialValue;
  final bool isPassword;
  final TextInputType keyboardType;
  final int maxLines;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final bool isRequired;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.initialValue,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.isRequired = false,
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
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.red),
                ),
            ],
          ),
          const SizedBox(height: AppDimens.xs + 2),
        ],
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          obscureText: isPassword,
          keyboardType: keyboardType,
          maxLines: isPassword ? 1 : maxLines,
          readOnly: readOnly,
          validator: validator,
          onChanged: onChanged,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 20, color: AppColors.outline)
                : null,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
