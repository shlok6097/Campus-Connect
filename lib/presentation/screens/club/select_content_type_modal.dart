import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/publication_model.dart';
import 'create_publication_sheet.dart';

class SelectContentTypeModal extends StatelessWidget {
  const SelectContentTypeModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SelectContentTypeModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _ContentTypeItem(
        type: PublicationType.news,
        title: 'News',
        icon: Icons.newspaper,
        color: const Color(0xFF24389C),
      ),
      _ContentTypeItem(
        type: PublicationType.announcement,
        title: 'Announcement',
        icon: Icons.campaign_outlined,
        color: const Color(0xFF008744),
      ),
      _ContentTypeItem(
        type: PublicationType.document,
        title: 'Document',
        icon: Icons.description_outlined,
        color: const Color(0xFF0057E7),
      ),
      _ContentTypeItem(
        type: PublicationType.quiz,
        title: 'Quiz',
        icon: Icons.psychology_outlined,
        color: const Color(0xFFFFA700),
      ),
      _ContentTypeItem(
        type: PublicationType.fact,
        title: 'Fact',
        icon: Icons.lightbulb_outline,
        color: const Color(0xFF8F4700),
      ),
      _ContentTypeItem(
        type: PublicationType.achievement,
        title: 'Achievement',
        icon: Icons.emoji_events_outlined,
        color: const Color(0xFFFFA700),
      ),
      _ContentTypeItem(
        type: PublicationType.project,
        title: 'Project',
        icon: Icons.rocket_launch_outlined,
        color: const Color(0xFF24389C),
      ),
      _ContentTypeItem(
        type: PublicationType.report,
        title: 'Report',
        icon: Icons.assessment_outlined,
        color: const Color(0xFF5C5F60),
      ),
      _ContentTypeItem(
        type: PublicationType.poll,
        title: 'Poll',
        icon: Icons.poll_outlined,
        color: const Color(0xFFD62D20),
      ),
      _ContentTypeItem(
        type: PublicationType.resource,
        title: 'Resource',
        icon: Icons.link,
        color: const Color(0xFF0057E7),
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: AppDimens.md,
        left: AppDimens.md,
        right: AppDimens.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppDimens.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: AppDimens.md),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Publish Something',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Divider(color: AppColors.outlineVariant, height: 1),
          const SizedBox(height: AppDimens.lg),

          // 3-Column Grid of Content Types
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: AppDimens.md,
              mainAxisSpacing: AppDimens.lg,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  CreatePublicationSheet.show(context, selectedType: item.type);
                },
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: item.color.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(item.icon, size: 28, color: item.color),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: AppDimens.md),
        ],
      ),
    );
  }
}

class _ContentTypeItem {
  final PublicationType type;
  final String title;
  final IconData icon;
  final Color color;

  const _ContentTypeItem({
    required this.type,
    required this.title,
    required this.icon,
    required this.color,
  });
}
