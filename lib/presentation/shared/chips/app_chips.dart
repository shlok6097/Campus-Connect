import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    this.backgroundColor = AppColors.greenLight,
    this.textColor = AppColors.greenDark,
    this.icon,
  });

  factory StatusBadge.success(String label, {IconData? icon}) {
    return StatusBadge(
      label: label,
      backgroundColor: AppColors.greenLight,
      textColor: AppColors.greenDark,
      icon: icon ?? Icons.check_circle_outline,
    );
  }

  factory StatusBadge.warning(String label, {IconData? icon}) {
    return StatusBadge(
      label: label,
      backgroundColor: AppColors.orangeLight,
      textColor: AppColors.orangeDark,
      icon: icon ?? Icons.schedule,
    );
  }

  factory StatusBadge.info(String label, {IconData? icon}) {
    return StatusBadge(
      label: label,
      backgroundColor: AppColors.blueLight,
      textColor: AppColors.blueDark,
      icon: icon,
    );
  }

  factory StatusBadge.error(String label, {IconData? icon}) {
    return StatusBadge(
      label: label,
      backgroundColor: AppColors.redLight,
      textColor: AppColors.redDark,
      icon: icon ?? Icons.error_outline,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.sm + 2, vertical: AppDimens.xs),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppDimens.borderPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: AppDimens.xs),
          ],
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class SkillChip extends StatelessWidget {
  final String label;
  final VoidCallback? onDeleted;
  final Color? backgroundColor;
  final Color? textColor;

  const SkillChip({
    super.key,
    required this.label,
    this.onDeleted,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.sm + 4, vertical: AppDimens.xs + 2),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.blueLight,
        borderRadius: AppDimens.borderMd,
        border: Border.all(color: (textColor ?? AppColors.blue).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: textColor ?? AppColors.blueDark,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (onDeleted != null) ...[
            const SizedBox(width: AppDimens.xs),
            GestureDetector(
              onTap: onDeleted,
              child: Icon(Icons.close, size: 14, color: textColor ?? AppColors.blueDark),
            ),
          ],
        ],
      ),
    );
  }
}

class CategoryFilterChip<T> extends StatelessWidget {
  final String label;
  final T? value;
  final T? selectedValue;
  final ValueChanged<T?> onSelected;
  final IconData? icon;

  const CategoryFilterChip({
    super.key,
    required this.label,
    required this.value,
    required this.selectedValue,
    required this.onSelected,
    this.icon,
  });

  bool get isSelected => value == selectedValue;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.blue : AppColors.white,
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected ? AppColors.blue : AppColors.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: () => onSelected(value),
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: AppDimens.sm),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? AppColors.white : AppColors.textSecondary,
                ),
                const SizedBox(width: AppDimens.xs + 2),
              ],
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? AppColors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
