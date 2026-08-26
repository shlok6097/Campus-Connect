import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';

class BentoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Border? border;
  final double? width;
  final double? height;

  const BentoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimens.md),
    this.onTap,
    this.backgroundColor = AppColors.white,
    this.border,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppDimens.borderXl,
        border: border ?? Border.all(color: AppColors.outlineVariant),
        boxShadow: AppDimens.cardShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppDimens.borderXl,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
