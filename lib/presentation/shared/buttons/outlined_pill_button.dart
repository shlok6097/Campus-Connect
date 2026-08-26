import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';

class OutlinedPillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color color;
  final Color? backgroundColor;

  const OutlinedPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = AppColors.blue,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? Colors.transparent,
      shape: StadiumBorder(side: BorderSide(color: color.withOpacity(0.4))),
      child: InkWell(
        onTap: onPressed,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: AppDimens.sm),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: color),
                const SizedBox(width: AppDimens.xs),
              ],
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
