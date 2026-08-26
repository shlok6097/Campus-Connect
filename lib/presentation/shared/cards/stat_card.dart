import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import 'bento_card.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color? backgroundColor;
  final String? subtitle;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor = AppColors.blue,
    this.backgroundColor,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      backgroundColor: backgroundColor ?? AppColors.white,
      padding: const EdgeInsets.all(AppDimens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 1.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(AppDimens.xs + 2),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: AppDimens.borderSm,
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sm),
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppDimens.xs),
            Text(
              subtitle!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
