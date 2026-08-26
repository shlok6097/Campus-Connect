import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/event_model.dart';
import '../../shared/buttons/primary_button.dart';
import '../../shared/cards/bento_card.dart';
import '../../shared/chips/app_chips.dart';
import '../../shared/headers/section_header.dart';
import '../../state/auth_controller.dart';
import '../../state/event_controller.dart';
import 'event_registration_modal.dart';

class EventDetailsScreen extends StatelessWidget {
  final EventModel event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: EventController.instance,
      builder: (context, _) {
        final isRegistered = EventController.instance.isUserRegistered(
          event.id,
          AuthController.instance.currentUser.studentId,
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // Sliver App Bar with Hero Image
                  SliverAppBar(
                    expandedHeight: 240,
                    pinned: true,
                    backgroundColor: AppColors.blueDark,
                    leading: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColors.white,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            event.bannerUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                Container(color: AppColors.blueDark),
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              gradient: AppColors.heroGradient,
                            ),
                          ),
                          Positioned(
                            bottom: AppDimens.md,
                            left: AppDimens.md,
                            right: AppDimens.md,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                StatusBadge.warning(
                                  event.category.name.toUpperCase(),
                                ),
                                const SizedBox(height: AppDimens.xs),
                                Text(
                                  event.title,
                                  style: AppTextStyles.displayLargeMobile
                                      .copyWith(
                                        color: AppColors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Event Content Details
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimens.marginMobile,
                        AppDimens.lg,
                        AppDimens.marginMobile,
                        100, // Padding for sticky bottom bar
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Meta Bento Grid (Date, Time, Venue, Seats)
                            _buildMetaBentoGrid(),
                            const SizedBox(height: AppDimens.xl),

                            // 2. About the Event
                            SectionHeader(
                              title: 'About the Event',
                              icon: Icons.info_outline,
                            ),
                            const SizedBox(height: AppDimens.sm),
                            BentoCard(
                              padding: const EdgeInsets.all(AppDimens.lg),
                              child: Text(
                                event.description,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textPrimary,
                                  height: 1.6,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppDimens.xl),

                            // 3. Prizes & Awards
                            if (event.prizes.isNotEmpty) ...[
                              SectionHeader(
                                title: 'Prizes & Awards',
                                icon: Icons.emoji_events_outlined,
                              ),
                              const SizedBox(height: AppDimens.sm),
                              _buildPrizesSection(),
                              const SizedBox(height: AppDimens.xl),
                            ],

                            // 4. Timeline & Schedule
                            if (event.timeline.isNotEmpty) ...[
                              SectionHeader(
                                title: 'Schedule & Timeline',
                                icon: Icons.timeline_outlined,
                              ),
                              const SizedBox(height: AppDimens.sm),
                              _buildTimelineSection(),
                              const SizedBox(height: AppDimens.xl),
                            ],

                            // 5. Rules & Eligibility
                            if (event.rules.isNotEmpty ||
                                event.eligibility.isNotEmpty) ...[
                              SectionHeader(
                                title: 'Rules & Requirements',
                                icon: Icons.gavel_outlined,
                              ),
                              const SizedBox(height: AppDimens.sm),
                              _buildRulesSection(),
                              const SizedBox(height: AppDimens.xl),
                            ],

                            // 6. Organizer Info
                            BentoCard(
                              padding: const EdgeInsets.all(AppDimens.lg),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.blueLight,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.hub,
                                      color: AppColors.blue,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: AppDimens.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Organized By',
                                          style: AppTextStyles.labelMedium,
                                        ),
                                        Text(
                                          event.organizerName,
                                          style: AppTextStyles.titleLarge
                                              .copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Sticky Bottom Registration Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.marginMobile,
                    vertical: AppDimens.md,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.outlineVariant,
                        width: 1,
                      ),
                    ),
                    boxShadow: AppDimens.topSheetShadow,
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Entry Fee',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              event.entryFee == 0
                                  ? 'FREE'
                                  : Formatters.formatCurrency(event.entryFee),
                              style: AppTextStyles.headlineSmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: AppDimens.md),
                        Expanded(
                          child: PrimaryButton(
                            label: isRegistered
                                ? 'Registered (View Pass)'
                                : 'Register Now',
                            icon: isRegistered
                                ? Icons.check_circle
                                : Icons.how_to_reg,
                            backgroundColor: isRegistered
                                ? AppColors.blue
                                : AppColors.green,
                            onPressed: () {
                              EventRegistrationModal.show(
                                context: context,
                                event: event,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetaBentoGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 500;
        return GridView.count(
          crossAxisCount: isDesktop ? 4 : 2,
          crossAxisSpacing: AppDimens.md,
          mainAxisSpacing: AppDimens.md,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: isDesktop ? 1.5 : 1.25,
          children: [
            _buildMetaCard(
              icon: Icons.calendar_today,
              iconColor: AppColors.blue,
              title: 'Date',
              value: Formatters.formatDate(event.startDate),
            ),
            _buildMetaCard(
              icon: Icons.access_time,
              iconColor: AppColors.orangeDark,
              title: 'Duration',
              value: event.timeString.split(',').last.trim(),
            ),
            _buildMetaCard(
              icon: Icons.location_on,
              iconColor: AppColors.red,
              title: 'Venue',
              value: event.venue.split('&').first.trim(),
            ),
            _buildMetaCard(
              icon: Icons.people,
              iconColor: AppColors.green,
              title: 'Capacity',
              value: '${event.registeredCount}/${event.maxParticipants}',
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetaCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return BentoCard(
      padding: const EdgeInsets.all(AppDimens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: AppTextStyles.labelMedium.copyWith(fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPrizesSection() {
    return Column(
      children: event.prizes.map((prize) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimens.sm),
          child: BentoCard(
            padding: const EdgeInsets.all(AppDimens.md),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimens.sm),
                  decoration: BoxDecoration(
                    color: AppColors.orangeLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: AppColors.orangeDark,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppDimens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prize.rankTitle,
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (prize.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          prize.description,
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                if (prize.amount.isNotEmpty)
                  Text(
                    prize.amount,
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.green,
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimelineSection() {
    return Column(
      children: List.generate(event.timeline.length, (index) {
        final item = event.timeline[index];
        final isLast = index == event.timeline.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppColors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: AppColors.outlineVariant,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppDimens.md),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : AppDimens.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: AppTextStyles.titleLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.time,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.blue,
                          ),
                        ),
                      ],
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.description,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildRulesSection() {
    return BentoCard(
      padding: const EdgeInsets.all(AppDimens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...event.rules.map(
            (rule) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: AppColors.green,
                  ),
                  const SizedBox(width: AppDimens.sm),
                  Expanded(child: Text(rule, style: AppTextStyles.bodyMedium)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
