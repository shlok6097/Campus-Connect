import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';

class ScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showBackButton;
  final VoidCallback? onBack;

  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  if (showBackButton) ...[
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.blue),
                      onPressed:
                          onBack ?? () => Navigator.of(context).maybePop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: AppDimens.sm),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.displayLargeMobile.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppDimens.xs),
          Text(
            subtitle!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
