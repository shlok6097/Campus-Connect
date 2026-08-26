import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final Color backgroundColor;
  final Color foregroundColor;
  final double height;
  final BorderRadius? borderRadius;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.backgroundColor = AppColors.green,
    this.foregroundColor = AppColors.white,
    this.height = 48.0,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final buttonContent = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          ),
          const SizedBox(width: AppDimens.xs + 2),
        ] else if (icon != null) ...[
          Icon(icon, size: 18, color: foregroundColor),
          const SizedBox(width: AppDimens.xs + 2),
        ],
        Flexible(
          child: Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? AppDimens.borderMd,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
        ),
        child: buttonContent,
      ),
    );
  }
}
