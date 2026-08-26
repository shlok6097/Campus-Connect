import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';

class CustomBottomSheet {
  CustomBottomSheet._();

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? subtitle,
    required Widget content,
    Widget? actionButton,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radius2Xl)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle grabber
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.outlineVariant,
                          borderRadius: AppDimens.borderPill,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimens.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: AppTextStyles.headlineMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: AppDimens.xs),
                                Text(
                                  subtitle,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.outline),
                          onPressed: () => Navigator.of(ctx).pop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.lg),
                    content,
                    if (actionButton != null) ...[
                      const SizedBox(height: AppDimens.xl),
                      actionButton,
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
