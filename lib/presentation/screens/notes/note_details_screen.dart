import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/note_model.dart';
import '../../shared/buttons/primary_button.dart';
import '../../shared/buttons/secondary_button.dart';
import '../../shared/cards/bento_card.dart';
import '../../shared/chips/app_chips.dart';
import '../../shared/headers/section_header.dart';

class NoteDetailsScreen extends StatelessWidget {
  final NoteModel note;

  const NoteDetailsScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: Text(
          'Note Details',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.blue,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.marginMobile),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Note Header & Meta Bento Card
              BentoCard(
                padding: const EdgeInsets.all(AppDimens.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.redLight,
                            borderRadius: AppDimens.borderLg,
                          ),
                          child: const Icon(Icons.description, color: AppColors.red, size: 36),
                        ),
                        const SizedBox(width: AppDimens.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      note.title,
                                      style: AppTextStyles.displayLargeMobile.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 22,
                                      ),
                                    ),
                                  ),
                                  StatusBadge.info(note.subject.name.toUpperCase()),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                note.description,
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.lg),
                    // Grid of 4 metadata items
                    Wrap(
                      spacing: AppDimens.md,
                      runSpacing: AppDimens.sm,
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        _buildMetaItem('AUTHOR', note.authorName),
                        _buildMetaItem('COURSE', note.course),
                        _buildMetaItem('UPLOADED', note.uploadDate),
                        _buildMetaItem('STATS', '${note.downloadCount} dl • ★ ${note.rating}'),
                      ],
                    ),
                    const SizedBox(height: AppDimens.xl),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            label: 'Read Note',
                            icon: Icons.menu_book,
                            backgroundColor: AppColors.blue,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Opening PDF reader...')),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: AppDimens.sm),
                        Expanded(
                          child: SecondaryButton(
                            label: 'Download PDF',
                            icon: Icons.download,
                            color: AppColors.blue,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Downloaded ${note.title} (${note.fileSize})')),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.lg),

              // 2. Topics Covered Bento Card
              BentoCard(
                padding: const EdgeInsets.all(AppDimens.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(title: 'Topics Covered', icon: Icons.format_list_bulleted),
                    const SizedBox(height: AppDimens.md),
                    Wrap(
                      spacing: AppDimens.sm,
                      runSpacing: AppDimens.sm,
                      children: note.topicsCovered
                          .map((topic) => SkillChip(
                                label: topic,
                                backgroundColor: AppColors.surfaceContainerLow,
                                textColor: AppColors.textPrimary,
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.lg),

              // 3. File Information Bento Card
              BentoCard(
                padding: const EdgeInsets.all(AppDimens.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(title: 'File Information', icon: Icons.info_outline),
                    const SizedBox(height: AppDimens.md),
                    _buildFileInfoRow('Format', note.fileFormat, icon: Icons.picture_as_pdf, iconColor: AppColors.red),
                    const Divider(height: AppDimens.lg),
                    _buildFileInfoRow('Size', note.fileSize),
                    const Divider(height: AppDimens.lg),
                    _buildFileInfoRow('Pages', '${note.pageCount} pages'),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.lg),

              // 4. Helpful Feedback Card
              BentoCard(
                padding: const EdgeInsets.all(AppDimens.lg),
                backgroundColor: AppColors.surfaceContainerLow,
                child: Column(
                  children: [
                    Text(
                      'Was this note helpful?',
                      style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppDimens.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Thank you for your feedback! 👍')),
                            );
                          },
                          icon: const Icon(Icons.thumb_up_alt_outlined, color: AppColors.green, size: 18),
                          label: const Text('Yes', style: TextStyle(color: AppColors.green)),
                        ),
                        const SizedBox(width: AppDimens.md),
                        OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Feedback recorded.')),
                            );
                          },
                          icon: const Icon(Icons.thumb_down_alt_outlined, color: AppColors.outline, size: 18),
                          label: const Text('No', style: TextStyle(color: AppColors.textSecondary)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium.copyWith(fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildFileInfoRow(String label, String value, {IconData? icon, Color? iconColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: iconColor ?? AppColors.blue),
              const SizedBox(width: 4),
            ],
            Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }
}
