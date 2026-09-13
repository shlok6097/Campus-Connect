import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/event_model.dart';
import '../../shared/buttons/primary_button.dart';
import '../../shared/cards/bento_card.dart';
import '../../shared/chips/app_chips.dart';
import '../../shared/feedback/empty_state_widget.dart';
import '../../shared/headers/screen_header.dart';
import '../../shared/inputs/app_search_bar.dart';
import '../../state/event_controller.dart';
import 'event_details_screen.dart';

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: EventController.instance,
      builder: (context, _) {
        final events = EventController.instance.filteredEvents;
        final selectedCat = EventController.instance.selectedCategory;

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
                // Header
                const ScreenHeader(
                  title: 'Campus Events',
                  subtitle:
                      'Discover workshops, hackathons, and campus competitions',
                ),
                const SizedBox(height: AppDimens.md),

                // Search bar
                AppSearchBar(
                  hint: 'Search events by name, organizer, or venue...',
                  controller: _searchController,
                  onChanged: (val) =>
                      EventController.instance.setSearchQuery(val),
                ),
                const SizedBox(height: AppDimens.md),

                // Category Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      CategoryFilterChip<EventCategory>(
                        label: 'All Events',
                        value: null,
                        selectedValue: selectedCat,
                        onSelected: (cat) =>
                            EventController.instance.setCategoryFilter(cat),
                      ),
                      const SizedBox(width: AppDimens.sm),
                      CategoryFilterChip<EventCategory>(
                        label: 'Hackathons',
                        value: EventCategory.hackathon,
                        selectedValue: selectedCat,
                        onSelected: (cat) =>
                            EventController.instance.setCategoryFilter(cat),
                      ),
                      const SizedBox(width: AppDimens.sm),
                      CategoryFilterChip<EventCategory>(
                        label: 'Technical',
                        value: EventCategory.technical,
                        selectedValue: selectedCat,
                        onSelected: (cat) =>
                            EventController.instance.setCategoryFilter(cat),
                      ),
                      const SizedBox(width: AppDimens.sm),
                      CategoryFilterChip<EventCategory>(
                        label: 'Workshops',
                        value: EventCategory.workshop,
                        selectedValue:
                            EventController.instance.selectedCategory,
                        onSelected: (cat) =>
                            EventController.instance.setCategoryFilter(cat),
                      ),
                      const SizedBox(width: AppDimens.sm),
                      CategoryFilterChip<EventCategory>(
                        label: 'Cultural',
                        value: EventCategory.cultural,
                        selectedValue: selectedCat,
                        onSelected: (cat) =>
                            EventController.instance.setCategoryFilter(cat),
                      ),
                      const SizedBox(width: AppDimens.sm),
                      CategoryFilterChip<EventCategory>(
                        label: 'Sports',
                        value: EventCategory.sports,
                        selectedValue: selectedCat,
                        onSelected: (cat) =>
                            EventController.instance.setCategoryFilter(cat),
                      ),
                      const SizedBox(width: AppDimens.sm),
                      CategoryFilterChip<EventCategory>(
                        label: 'Competitions',
                        value: EventCategory.competition,
                        selectedValue: selectedCat,
                        onSelected: (cat) =>
                            EventController.instance.setCategoryFilter(cat),
                      ),
                      const SizedBox(width: AppDimens.sm),
                      CategoryFilterChip<EventCategory>(
                        label: 'Others',
                        value: EventCategory.others,
                        selectedValue: selectedCat,
                        onSelected: (cat) =>
                            EventController.instance.setCategoryFilter(cat),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.lg),

                // Events Count
                Text(
                  'Showing ${events.length} events',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimens.md),

                // Events List / Empty State
                if (events.isEmpty)
                  EmptyStateWidget(
                    icon: Icons.event_busy,
                    title: 'No Events Found',
                    description:
                        'Try adjusting your search query or category filter.',
                    actionLabel: 'Clear Filters',
                    onAction: () {
                      _searchController.clear();
                      EventController.instance.setSearchQuery('');
                      EventController.instance.setCategoryFilter(null);
                    },
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: events.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppDimens.lg),
                    itemBuilder: (ctx, index) =>
                        _buildEventCard(context, events[index]),
                  ),
                const SizedBox(height: AppDimens.xxl),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventCard(BuildContext context, EventModel event) {
    return BentoCard(
      padding: EdgeInsets.zero,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => EventDetailsScreen(event: event)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimens.radiusXl),
                ),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: Image.network(
                    event.bannerUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: AppColors.blueDark,
                      child: const Center(
                        child: Icon(
                          Icons.event,
                          color: AppColors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: AppDimens.md,
                left: AppDimens.md,
                child: StatusBadge.info(event.category.name.toUpperCase()),
              ),
              Positioned(
                top: AppDimens.md,
                right: AppDimens.md,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.sm,
                    vertical: AppDimens.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: AppDimens.borderPill,
                  ),
                  child: Text(
                    '${event.availableSeats} seats left',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimens.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      event.entryFee == 0
                          ? 'FREE'
                          : Formatters.formatCurrency(event.entryFee),
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.xs),
                Text(
                  event.description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimens.md),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: AppColors.blue,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      event.timeString,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.red,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      event.venue,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.lg),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        label: 'View Details & Register',
                        backgroundColor: AppColors.green,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => EventDetailsScreen(event: event),
                            ),
                          );
                        },
                      ),
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
