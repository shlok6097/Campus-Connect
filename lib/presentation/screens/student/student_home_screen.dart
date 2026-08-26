import 'package:flutter/material.dart';
import '../../../core/constants/asset_constants.dart';
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
import '../events/event_details_screen.dart';
import '../notes/notes_home_screen.dart';
import '../teams/teams_hub_screen.dart';

class StudentHomeScreen extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const StudentHomeScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        AuthController.instance,
        EventController.instance,
      ]),
      builder: (context, _) {
        final user = AuthController.instance.currentUser;
        final featured = EventController.instance.featuredEvent;
        final events = EventController.instance.allEvents;

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
                // 1. User Greeting Bento Header
                _buildGreetingCard(user),
                const SizedBox(height: AppDimens.lg),

                // 2. Featured Event Hero Banner
                if (featured != null) ...[
                  _buildFeaturedEventBanner(context, featured),
                  const SizedBox(height: AppDimens.xl),
                ],

                // 3. Bento Quick Actions (Find Events, My Teams, Clubs, Notes, Games)
                SectionHeader(
                  title: 'Quick Actions',
                  icon: Icons.dashboard_customize_outlined,
                ),
                const SizedBox(height: AppDimens.md),
                _buildQuickActionsGrid(context),
                const SizedBox(height: AppDimens.xl),

                // 4. Upcoming Events Section
                SectionHeader(
                  title: 'Upcoming Events',
                  icon: Icons.event_available_outlined,
                  actionText: 'View All',
                  onAction: () => onNavigateTab?.call(1),
                ),
                const SizedBox(height: AppDimens.md),
                _buildUpcomingEventsList(context, events),
                const SizedBox(height: AppDimens.xl),

                // 5. GDG Campus Announcements
                SectionHeader(
                  title: 'Campus Announcements',
                  icon: Icons.campaign_outlined,
                ),
                const SizedBox(height: AppDimens.md),
                _buildAnnouncementsSection(),
                const SizedBox(height: AppDimens.xxl),

                // Footer
                Center(
                  child: Text(
                    'Powered by GDG UVCE',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.outline,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.xl),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGreetingCard(user) {
    return BentoCard(
      padding: const EdgeInsets.all(AppDimens.md),
      backgroundColor: AppColors.white,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerHigh,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              user.avatarUrl.isNotEmpty
                  ? user.avatarUrl
                  : AssetConstants.avatarRahul,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.person, color: AppColors.blue, size: 28),
            ),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hello, ${user.name} 👋',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: 18,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${user.branch} • Sem ${user.semester}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.sm + 2,
              vertical: AppDimens.xs + 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.orangeLight,
              borderRadius: AppDimens.borderPill,
              border: Border.all(color: AppColors.orange.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars, size: 16, color: AppColors.orangeDark),
                const SizedBox(width: 4),
                Text(
                  '${user.totalPoints} pts',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.orangeDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedEventBanner(BuildContext context, EventModel event) {
    return BentoCard(
      padding: EdgeInsets.zero,
      backgroundColor: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image with Overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimens.radiusXl),
                ),
                child: SizedBox(
                  height: 180,
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
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: AppDimens.md,
                left: AppDimens.md,
                right: AppDimens.md,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: StatusBadge.warning(
                        'FEATURED EVENT',
                        icon: Icons.local_fire_department,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.sm,
                        vertical: AppDimens.xs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: AppDimens.borderPill,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.people_outline,
                            size: 14,
                            color: AppColors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${event.registeredCount}/${event.maxParticipants} Seats',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.white,
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
          Padding(
            padding: const EdgeInsets.all(AppDimens.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
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
                      Icons.calendar_today,
                      size: 16,
                      color: AppColors.blue,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        event.timeString,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.xs + 2),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.red,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        event.venue,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.lg),
                PrimaryButton(
                  label: 'View Event Details',
                  icon: Icons.arrow_forward,
                  backgroundColor: AppColors.green,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EventDetailsScreen(event: event),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 600;
        return GridView.count(
          crossAxisCount: isDesktop ? 4 : 2,
          crossAxisSpacing: AppDimens.md,
          mainAxisSpacing: AppDimens.md,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: isDesktop ? 1.4 : 1.15,
          children: [
            _buildActionItem(
              title: 'Find Events',
              subtitle: 'Workshops & Hackathons',
              icon: Icons.calendar_month,
              iconColor: AppColors.blue,
              bgColor: AppColors.blueLight,
              onTap: () => onNavigateTab?.call(1),
            ),
            _buildActionItem(
              title: 'My Teams',
              subtitle: 'Hackathon Workspaces',
              icon: Icons.group,
              iconColor: AppColors.green,
              bgColor: AppColors.greenLight,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TeamsHubScreen()),
                );
              },
            ),
            _buildActionItem(
              title: 'Campus Clubs',
              subtitle: 'Join Societies',
              icon: Icons.groups,
              iconColor: AppColors.orangeDark,
              bgColor: AppColors.orangeLight,
              onTap: () => onNavigateTab?.call(2),
            ),
            _buildActionItem(
              title: 'Lecture Notes',
              subtitle: 'Share & Download',
              icon: Icons.description,
              iconColor: AppColors.red,
              bgColor: AppColors.redLight,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NotesHomeScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return BentoCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppDimens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimens.sm),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: AppDimens.borderMd,
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(height: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventsList(
    BuildContext context,
    List<EventModel> events,
  ) {
    return SizedBox(
      height: 225,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: events.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppDimens.md),
        itemBuilder: (ctx, index) {
          final event = events[index];
          return SizedBox(
            width: 280,
            child: BentoCard(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EventDetailsScreen(event: event),
                  ),
                );
              },
              padding: const EdgeInsets.all(AppDimens.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatusBadge.info(event.category.name.toUpperCase()),
                      Text(
                        Formatters.formatDate(event.startDate),
                        style: AppTextStyles.labelMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.xs),
                  Text(
                    event.title,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    event.description,
                    style: AppTextStyles.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimens.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppColors.outline,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event.venue.split('&').first.trim(),
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppColors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnnouncementsSection() {
    return BentoCard(
      padding: const EdgeInsets.all(AppDimens.lg),
      child: Column(
        children: [
          _buildAnnouncementItem(
            tag: 'GDG UVCE',
            title: 'Registrations Open for Hackathon 2026',
            time: '2 hours ago',
            tagColor: AppColors.blue,
          ),
          const Divider(height: AppDimens.lg),
          _buildAnnouncementItem(
            tag: 'Coding Club',
            title: 'Weekly Problem Set #12 is now live in Technical Games',
            time: 'Yesterday',
            tagColor: AppColors.green,
          ),
          const Divider(height: AppDimens.lg),
          _buildAnnouncementItem(
            tag: 'Exam Cell',
            title:
                'Midterm schedule published. Check Lecture Notes for revision sheets.',
            time: '3 days ago',
            tagColor: AppColors.orangeDark,
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementItem({
    required String tag,
    required String title,
    required String time,
    required Color tagColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: tagColor.withOpacity(0.12),
            borderRadius: AppDimens.borderPill,
          ),
          child: Text(
            tag,
            style: AppTextStyles.labelMedium.copyWith(
              color: tagColor,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(width: AppDimens.sm + 2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(time, style: AppTextStyles.bodySmall.copyWith(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}
