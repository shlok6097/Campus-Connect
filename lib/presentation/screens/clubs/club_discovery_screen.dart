import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/club_model.dart';
import '../../shared/buttons/primary_button.dart';
import '../../shared/cards/bento_card.dart';
import '../../shared/chips/app_chips.dart';
import '../../shared/headers/screen_header.dart';
import '../../shared/headers/section_header.dart';
import '../../shared/inputs/app_search_bar.dart';
import '../../state/club_controller.dart';
import 'club_details_screen.dart';
import 'my_clubs_screen.dart';

class ClubDiscoveryScreen extends StatefulWidget {
  const ClubDiscoveryScreen({super.key});

  @override
  State<ClubDiscoveryScreen> createState() => _ClubDiscoveryScreenState();
}

class _ClubDiscoveryScreenState extends State<ClubDiscoveryScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ClubController.instance.loadClubs();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ClubController.instance,
      builder: (context, _) {
        final clubCtrl = ClubController.instance;
        final clubs = clubCtrl.filteredClubs;
        final myClubs = clubCtrl.myClubs;
        final selectedCat = clubCtrl.selectedCategory;

        return RefreshIndicator(
          onRefresh: () => clubCtrl.loadClubs(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.marginMobile,
              vertical: AppDimens.lg,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: ScreenHeader(
                          title: 'Campus Clubs',
                          subtitle: 'Discover, join, and lead student communities',
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const MyClubsScreen()),
                          );
                        },
                        icon: const Icon(Icons.bookmark_outline, size: 18, color: AppColors.blue),
                        label: Text(
                          'My Clubs (${myClubs.length})',
                          style: AppTextStyles.labelMedium.copyWith(color: AppColors.blue),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.md),

                  // Search Bar
                  AppSearchBar(
                    hint: 'Search clubs by name or domain...',
                    controller: _searchController,
                    onChanged: (val) => clubCtrl.setSearchQuery(val),
                  ),
                  const SizedBox(height: AppDimens.md),

                  // Category Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        CategoryFilterChip<ClubCategory>(
                          label: 'All Clubs',
                          value: null,
                          selectedValue: selectedCat,
                          onSelected: (cat) => clubCtrl.setCategoryFilter(cat),
                        ),
                        const SizedBox(width: AppDimens.sm),
                        CategoryFilterChip<ClubCategory>(
                          label: 'Technical',
                          value: ClubCategory.technical,
                          selectedValue: selectedCat,
                          onSelected: (cat) => clubCtrl.setCategoryFilter(cat),
                        ),
                        const SizedBox(width: AppDimens.sm),
                        CategoryFilterChip<ClubCategory>(
                          label: 'Cultural',
                          value: ClubCategory.cultural,
                          selectedValue: selectedCat,
                          onSelected: (cat) => clubCtrl.setCategoryFilter(cat),
                        ),
                        const SizedBox(width: AppDimens.sm),
                        CategoryFilterChip<ClubCategory>(
                          label: 'Sports',
                          value: ClubCategory.sports,
                          selectedValue: selectedCat,
                          onSelected: (cat) => clubCtrl.setCategoryFilter(cat),
                        ),
                        const SizedBox(width: AppDimens.sm),
                        CategoryFilterChip<ClubCategory>(
                          label: 'Academic',
                          value: ClubCategory.academic,
                          selectedValue: selectedCat,
                          onSelected: (cat) => clubCtrl.setCategoryFilter(cat),
                        ),
                        const SizedBox(width: AppDimens.sm),
                        CategoryFilterChip<ClubCategory>(
                          label: 'Creative & Media',
                          value: ClubCategory.creative,
                          selectedValue: selectedCat,
                          onSelected: (cat) => clubCtrl.setCategoryFilter(cat),
                        ),
                        const SizedBox(width: AppDimens.sm),
                        CategoryFilterChip<ClubCategory>(
                          label: 'Others',
                          value: ClubCategory.others,
                          selectedValue: selectedCat,
                          onSelected: (cat) => clubCtrl.setCategoryFilter(cat),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.xl),

                  // Loading State
                  if (clubCtrl.isLoading && clubs.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  // Empty State
                  else if (clubs.isEmpty)
                    BentoCard(
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.groups_outlined, size: 48, color: AppColors.outline),
                            const SizedBox(height: AppDimens.md),
                            Text(
                              'No clubs found',
                              style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: AppDimens.xs),
                            Text(
                              'Try selecting another category or clear search query.',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    // Featured Club
                    SectionHeader(title: 'Featured Club', icon: Icons.star_outline),
                    const SizedBox(height: AppDimens.sm),
                    _buildFeaturedClubCard(context, clubs.first),
                    const SizedBox(height: AppDimens.xl),

                    // Discover More Grid
                    SectionHeader(title: 'Discover All Clubs (${clubs.length})', icon: Icons.explore_outlined),
                    const SizedBox(height: AppDimens.sm),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth > 600;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isDesktop ? 2 : 1,
                            crossAxisSpacing: AppDimens.md,
                            mainAxisSpacing: AppDimens.md,
                            childAspectRatio: isDesktop ? 1.4 : 1.35,
                          ),
                          itemCount: clubs.length,
                          itemBuilder: (ctx, index) => _buildClubGridItem(context, clubs[index]),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: AppDimens.xxl),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturedClubCard(BuildContext context, ClubModel club) {
    return BentoCard(
      padding: const EdgeInsets.all(AppDimens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: AppDimens.borderLg,
                  color: AppColors.blueLight,
                ),
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                child: club.logoUrl.isNotEmpty
                    ? Image.network(
                        club.logoUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Text(
                          club.name.isNotEmpty ? club.name[0].toUpperCase() : 'C',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blue,
                          ),
                        ),
                      )
                    : Text(
                        club.name.isNotEmpty ? club.name[0].toUpperCase() : 'C',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blue,
                        ),
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
                            club.name,
                            style: AppTextStyles.headlineSmall.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge.info('${club.memberCount} Members'),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      club.tagline.isNotEmpty ? club.tagline : club.category.name.toUpperCase(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (club.description.isNotEmpty) ...[
            const SizedBox(height: AppDimens.md),
            Text(
              club.description,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: AppDimens.lg),
          Wrap(
            spacing: AppDimens.md,
            runSpacing: AppDimens.sm,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '${club.members.length} active member${club.members.length == 1 ? '' : 's'}',
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.greenDark),
              ),
              PrimaryButton(
                label: 'View Club & Activities',
                icon: Icons.arrow_forward,
                isFullWidth: false,
                backgroundColor: AppColors.green,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ClubDetailsScreen(club: club)),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClubGridItem(BuildContext context, ClubModel club) {
    return BentoCard(
      padding: const EdgeInsets.all(AppDimens.md),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ClubDetailsScreen(club: club)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: AppDimens.borderMd,
                  color: AppColors.blueLight,
                ),
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                child: club.logoUrl.isNotEmpty
                    ? Image.network(
                        club.logoUrl,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Text(
                          club.name.isNotEmpty ? club.name[0].toUpperCase() : 'C',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blue,
                          ),
                        ),
                      )
                    : Text(
                        club.name.isNotEmpty ? club.name[0].toUpperCase() : 'C',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blue,
                        ),
                      ),
              ),
              const SizedBox(width: AppDimens.sm + 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      club.name,
                      style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${club.memberCount} Members • ${club.category.name.toUpperCase()}',
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.xs),
          Text(
            club.description.isNotEmpty ? club.description : 'Official campus student organization.',
            style: AppTextStyles.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (club.isUserJoined)
                StatusBadge.success('Joined')
              else
                Text('Open to Join', style: AppTextStyles.labelMedium.copyWith(color: AppColors.blue)),
              const Icon(Icons.arrow_forward, size: 16, color: AppColors.blue),
            ],
          ),
        ],
      ),
    );
  }
}
