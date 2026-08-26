import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/note_model.dart';
import '../../shared/buttons/primary_button.dart';
import '../../shared/cards/bento_card.dart';
import '../../shared/chips/app_chips.dart';
import '../../shared/headers/screen_header.dart';
import '../../shared/headers/section_header.dart';
import '../../shared/inputs/app_search_bar.dart';
import '../../state/note_controller.dart';
import 'note_details_screen.dart';
import 'contribute_notes_screen.dart';
import 'note_leaderboard_screen.dart';

class NotesHomeScreen extends StatefulWidget {
  const NotesHomeScreen({super.key});

  @override
  State<NotesHomeScreen> createState() => _NotesHomeScreenState();
}

class _NotesHomeScreenState extends State<NotesHomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          'Lecture Notes',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: NoteController.instance,
        builder: (context, _) {
          final notes = NoteController.instance.filteredNotes;
          final selectedSubj = NoteController.instance.selectedSubject;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.marginMobile,
              vertical: AppDimens.lg,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header & Leaderboard shortcut
                  Wrap(
                    spacing: AppDimens.md,
                    runSpacing: AppDimens.sm,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const ScreenHeader(
                        title: 'Lecture Notes',
                        subtitle:
                            'Community-verified engineering lecture notes & guides',
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const NoteLeaderboardScreen(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.leaderboard_outlined,
                          size: 18,
                          color: AppColors.blue,
                        ),
                        label: Text(
                          'Leaderboard',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.lg),

                  // Contribute Hero CTA Card
                  _buildContributeBanner(context),
                  const SizedBox(height: AppDimens.xl),

                  // Search Bar
                  AppSearchBar(
                    hint:
                        'Search by topic, course, or keyword (e.g. Trees, Semaphore)...',
                    controller: _searchController,
                    onChanged: (val) =>
                        NoteController.instance.setSearchQuery(val),
                  ),
                  const SizedBox(height: AppDimens.md),

                  // Subject Filters
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        CategoryFilterChip<NoteSubject>(
                          label: 'All Subjects',
                          value: null,
                          selectedValue: selectedSubj,
                          onSelected: (s) =>
                              NoteController.instance.setSubjectFilter(s),
                        ),
                        const SizedBox(width: AppDimens.sm),
                        CategoryFilterChip<NoteSubject>(
                          label: 'DSA',
                          value: NoteSubject.dsa,
                          selectedValue: selectedSubj,
                          onSelected: (s) =>
                              NoteController.instance.setSubjectFilter(s),
                        ),
                        const SizedBox(width: AppDimens.sm),
                        CategoryFilterChip<NoteSubject>(
                          label: 'Operating Systems',
                          value: NoteSubject.os,
                          selectedValue: selectedSubj,
                          onSelected: (s) =>
                              NoteController.instance.setSubjectFilter(s),
                        ),
                        const SizedBox(width: AppDimens.sm),
                        CategoryFilterChip<NoteSubject>(
                          label: 'DBMS',
                          value: NoteSubject.dbms,
                          selectedValue: selectedSubj,
                          onSelected: (s) =>
                              NoteController.instance.setSubjectFilter(s),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.xl),

                  // Notes List
                  SectionHeader(
                    title: 'Available Notes',
                    icon: Icons.menu_book_outlined,
                  ),
                  const SizedBox(height: AppDimens.md),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: notes.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppDimens.md),
                    itemBuilder: (ctx, index) =>
                        _buildNoteCard(context, notes[index]),
                  ),
                  const SizedBox(height: AppDimens.xxl),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContributeBanner(BuildContext context) {
    return BentoCard(
      padding: const EdgeInsets.all(AppDimens.lg),
      backgroundColor: AppColors.blueLight,
      border: Border.all(color: AppColors.blue.withOpacity(0.3)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimens.md),
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.upload_file,
              color: AppColors.blue,
              size: 28,
            ),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contribute & Earn Points',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.blueDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Share your handwritten or PDF notes to climb the university leaderboard.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.sm),
          PrimaryButton(
            label: 'Contribute',
            icon: Icons.add,
            isFullWidth: false,
            backgroundColor: AppColors.blue,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ContributeNotesScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, NoteModel note) {
    return BentoCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => NoteDetailsScreen(note: note)),
        );
      },
      padding: const EdgeInsets.all(AppDimens.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.redLight,
              borderRadius: AppDimens.borderMd,
            ),
            child: const Center(
              child: Icon(Icons.picture_as_pdf, color: AppColors.red, size: 30),
            ),
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
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    StatusBadge.info(note.subject.name.toUpperCase()),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  note.description,
                  style: AppTextStyles.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimens.sm),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'By ${note.authorName} • ${note.course}',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.star,
                      size: 14,
                      color: AppColors.orangeDark,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${note.rating}',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.download_outlined,
                      size: 14,
                      color: AppColors.outline,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${note.downloadCount}',
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
