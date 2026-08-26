import 'package:flutter/material.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';

class TopAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showLeadingAvatar;
  final String? avatarUrl;
  final bool showNotifications;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarTap;
  final bool showBackButton;
  final VoidCallback? onBackTap;
  final List<Widget>? actions;

  const TopAppBarWidget({
    super.key,
    this.title = 'Campus Connect',
    this.showLeadingAvatar = true,
    this.avatarUrl,
    this.showNotifications = true,
    this.onNotificationTap,
    this.onAvatarTap,
    this.showBackButton = false,
    this.onBackTap,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      titleSpacing: showBackButton || showLeadingAvatar ? 0 : AppDimens.marginMobile,
      leadingWidth: showBackButton || showLeadingAvatar ? 56 : 0,
      leading: _buildLeading(context),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.blue,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(
          height: 1,
          thickness: 1,
          color: AppColors.outlineVariant,
        ),
      ),
      actions: [
        if (actions != null) ...actions!,
        if (showNotifications)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  tooltip: 'Notifications',
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                  onPressed:
                      onNotificationTap ??
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No new notifications'),
                            duration: Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.orangeDark,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (showBackButton) {
      return IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.blue),
        onPressed: onBackTap ?? () => Navigator.of(context).maybePop(),
      );
    }

    if (showLeadingAvatar) {
      return Center(
        child: InkWell(
          onTap: onAvatarTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.blue.withValues(alpha: 0.25),
                width: 1.5,
              ),
              color: AppColors.surfaceContainerHigh,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              avatarUrl ?? AssetConstants.avatarRahul,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(
                Icons.person,
                color: AppColors.blue,
                size: 20,
              ),
            ),
          ),
        ),
      );
    }

    return null;
  }
}
