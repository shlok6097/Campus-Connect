import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/publication_model.dart';
import '../../state/auth_controller.dart';
import '../../state/publish_controller.dart';
import 'select_content_type_modal.dart';

class PublishHubScreen extends StatefulWidget {
  const PublishHubScreen({super.key});

  @override
  State<PublishHubScreen> createState() => _PublishHubScreenState();
}

class _PublishHubScreenState extends State<PublishHubScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = AuthController.instance.currentUser;
      PublishController.instance.loadPublications(
        clubName: user.clubName,
        clubId: user.clubId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: PublishController.instance,
      builder: (context, _) {
        final ctrl = PublishController.instance;
        final publications = ctrl.filteredPublications;

        final filterOptions = [
          'ALL',
          'NEWS',
          'ANNOUNCEMENT',
          'QUIZ',
          'DOCUMENT',
          'POLL',
          'FACT',
          'ACHIEVEMENT',
          'PROJECT',
          'RESOURCE',
          'REPORT',
        ];

        return Scaffold(
          backgroundColor: AppColors.background,
          body: RefreshIndicator(
            onRefresh: () {
              final user = AuthController.instance.currentUser;
              return ctrl.loadPublications(
                clubName: user.clubName,
                clubId: user.clubId,
              );
            },
            color: const Color(0xFF24389C),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.marginMobile,
                vertical: AppDimens.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header with Title & + Publish Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Publish',
                              style: AppTextStyles.headlineMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Share updates, quizzes, and polls with your club',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => SelectContentTypeModal.show(context),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Publish'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF24389C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.md),

                  // Search Bar
                  TextField(
                    onChanged: ctrl.setSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Search published content...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.outlineVariant,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.outlineVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.sm),

                  // Filter Chips
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: filterOptions.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final filter = filterOptions[index];
                        final isSelected = ctrl.selectedFilter == filter;
                        return ChoiceChip(
                          label: Text(
                            filter,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFF24389C),
                          backgroundColor: AppColors.surface,
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF24389C)
                                : AppColors.outlineVariant,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onSelected: (_) => ctrl.setFilter(filter),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppDimens.md),

                  // Content Grid / List
                  if (ctrl.isLoading && ctrl.allPublications.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppDimens.xxl),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (publications.isEmpty)
                    _buildEmptyState(context)
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: publications.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppDimens.md),
                      itemBuilder: (context, index) {
                        final pub = publications[index];
                        return _buildPublicationCard(context, pub);
                      },
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF24389C).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.post_add,
              size: 48,
              color: Color(0xFF24389C),
            ),
          ),
          const SizedBox(height: AppDimens.md),
          Text(
            'No Publications Found',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Publish announcements, interactive quizzes, polls, facts, and documents for your club members.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimens.lg),
          ElevatedButton.icon(
            onPressed: () => SelectContentTypeModal.show(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Publish Something'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF24389C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublicationCard(BuildContext context, PublicationModel pub) {
    final dateStr = DateFormat('d MMM yyyy, h:mm a').format(pub.createdAt);

    Color tagBg;
    Color tagText;
    IconData typeIcon;

    switch (pub.type) {
      case PublicationType.quiz:
        tagBg = const Color(0xFFFFA700).withValues(alpha: 0.15);
        tagText = const Color(0xFF8F4700);
        typeIcon = Icons.psychology_outlined;
        break;
      case PublicationType.document:
      case PublicationType.report:
        tagBg = const Color(0xFF0057E7).withValues(alpha: 0.12);
        tagText = const Color(0xFF0057E7);
        typeIcon = Icons.description_outlined;
        break;
      case PublicationType.poll:
        tagBg = const Color(0xFFD62D20).withValues(alpha: 0.12);
        tagText = const Color(0xFFD62D20);
        typeIcon = Icons.poll_outlined;
        break;
      case PublicationType.fact:
        tagBg = const Color(0xFF8F4700).withValues(alpha: 0.12);
        tagText = const Color(0xFF8F4700);
        typeIcon = Icons.lightbulb_outline;
        break;
      case PublicationType.achievement:
        tagBg = const Color(0xFFFFA700).withValues(alpha: 0.15);
        tagText = const Color(0xFF8F4700);
        typeIcon = Icons.emoji_events_outlined;
        break;
      case PublicationType.news:
      case PublicationType.announcement:
      default:
        tagBg = const Color(0xFF24389C).withValues(alpha: 0.1);
        tagText = const Color(0xFF24389C);
        typeIcon = Icons.campaign_outlined;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppDimens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Pill Tag & Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: tagBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(typeIcon, size: 14, color: tagText),
                    const SizedBox(width: 4),
                    Text(
                      pub.type.tag,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: tagText,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                onSelected: (val) {
                  if (val == 'delete') {
                    PublishController.instance.deletePublication(pub.id);
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: AppColors.red,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: AppColors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            pub.title,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),

          // Body Content
          if (pub.content.isNotEmpty)
            Text(
              pub.content,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

          // Type-Specific Widget Rendering (Poll options, Quiz stats, Document size)
          if (pub.type == PublicationType.poll) ...[
            const SizedBox(height: AppDimens.md),
            _buildPollSection(context, pub),
          ] else if (pub.type == PublicationType.quiz) ...[
            const SizedBox(height: AppDimens.md),
            _buildQuizSection(context, pub),
          ] else if (pub.type == PublicationType.document ||
              pub.type == PublicationType.report) ...[
            const SizedBox(height: AppDimens.md),
            _buildDocumentSection(context, pub),
          ],

          const SizedBox(height: AppDimens.md),
          const Divider(color: AppColors.outlineVariant, height: 1),
          const SizedBox(height: 8),

          // Footer info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'By ${pub.authorName} • $dateStr',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.favorite_border,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${pub.likesCount}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.visibility_outlined,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${pub.viewsCount}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPollSection(BuildContext context, PublicationModel pub) {
    final meta = pub.metadata;
    final options = (meta['options'] as List?) ?? [];
    final totalVotes = meta['total_votes'] as int? ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(options.length, (idx) {
          final opt = options[idx];
          final label = opt['label'] ?? 'Option';
          final percent = opt['percent'] ?? 0;
          final votes = opt['votes'] ?? 0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => PublishController.instance.voteOnPoll(pub.id, idx),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$percent% ($votes)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percent / 100.0,
                        backgroundColor: AppColors.outlineVariant.withValues(
                          alpha: 0.3,
                        ),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF24389C),
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(
              Icons.how_to_vote,
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              '$totalVotes total votes • Tap an option to vote',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuizSection(BuildContext context, PublicationModel pub) {
    final participants = pub.metadata['participants'] ?? 85;
    final questions = pub.metadata['questions_count'] ?? 10;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFA700).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFFFA700).withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.group, size: 18, color: Color(0xFF8F4700)),
              const SizedBox(width: 6),
              Text(
                '$participants participants',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8F4700),
                ),
              ),
            ],
          ),
          Text(
            '$questions Questions',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentSection(BuildContext context, PublicationModel pub) {
    final fileType = pub.metadata['file_type'] ?? 'PDF';
    final fileSize = pub.metadata['file_size'] ?? '4.2 MB';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0057E7).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF0057E7).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.description, size: 20, color: Color(0xFF0057E7)),
              const SizedBox(width: 8),
              Text(
                '$fileType • $fileSize',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0057E7),
                ),
              ),
            ],
          ),
          const Icon(Icons.download, size: 18, color: Color(0xFF0057E7)),
        ],
      ),
    );
  }
}
