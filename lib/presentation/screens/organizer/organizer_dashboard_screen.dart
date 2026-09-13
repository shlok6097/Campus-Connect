import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/event_model.dart';
import '../../shared/buttons/primary_button.dart';
import '../../shared/cards/bento_card.dart';
import '../../shared/cards/stat_card.dart';
import '../../shared/chips/app_chips.dart';
import '../../shared/headers/screen_header.dart';
import '../../shared/headers/section_header.dart';
import '../../state/auth_controller.dart';
import '../../state/club_controller.dart';
import '../../state/event_controller.dart';
import 'create_event_screen.dart';
import 'export_data_modal.dart';
import 'registration_responses_screen.dart';

class OrganizerDashboardScreen extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const OrganizerDashboardScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        EventController.instance,
        ClubController.instance,
      ]),
      builder: (context, _) {
        final events = EventController.instance.allEvents;
        final registrations = EventController.instance.allRegistrations;
        final user = AuthController.instance.currentUser;
        final myClub = ClubController.instance.allClubs
            .where((c) => c.id == user.clubId)
            .firstOrNull;
        final myClubMembers = myClub?.memberCount ??
            ClubController.instance.allClubs.fold<int>(0, (sum, c) => sum + c.memberCount);

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
                // Header & Create Event Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: ScreenHeader(
                        title: 'Organizer Hub',
                        subtitle:
                            'Overview of events, attendance, and registration forms',
                      ),
                    ),
                    PrimaryButton(
                      label: 'Create Event',
                      icon: Icons.add,
                      isFullWidth: false,
                      backgroundColor: AppColors.green,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CreateEventScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.lg),

                // 4 Stat Bento Cards
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth > 650;
                    return GridView.count(
                      crossAxisCount: isDesktop ? 4 : 2,
                      crossAxisSpacing: AppDimens.md,
                      mainAxisSpacing: AppDimens.md,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: isDesktop ? 1.5 : 1.3,
                      children: [
                        StatCard(
                          title: 'Total Events',
                          value: '${events.length}',
                          icon: Icons.event,
                          iconColor: AppColors.blue,
                          subtitle: '${events.where((e) => e.isPublished).length} published',
                        ),
                        StatCard(
                          title: 'Club Members',
                          value: '$myClubMembers',
                          icon: Icons.groups,
                          iconColor: AppColors.green,
                          subtitle: myClub != null ? myClub.name : 'All registered',
                        ),
                        StatCard(
                          title: 'Registrations',
                          value: '${registrations.length}',
                          icon: Icons.how_to_reg,
                          iconColor: AppColors.orangeDark,
                          subtitle: 'Total tickets issued',
                        ),
                        StatCard(
                          title: 'Active Events',
                          value: '${events.where((e) => e.isPublished).length}',
                          icon: Icons.local_fire_department,
                          iconColor: AppColors.red,
                          subtitle: 'Live for registration',
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppDimens.xl),

                // Quick Actions Bento Row
                SectionHeader(
                  title: 'Quick Operations',
                  icon: Icons.bolt_outlined,
                ),
                const SizedBox(height: AppDimens.sm),
                _buildQuickOperationsRow(context),
                const SizedBox(height: AppDimens.xl),

                // Managed Events Roster
                SectionHeader(
                  title: 'Managed Events',
                  icon: Icons.calendar_month_outlined,
                  actionText: 'View All',
                  onAction: () => onNavigateTab?.call(1),
                ),
                const SizedBox(height: AppDimens.sm),
                if (events.isEmpty)
                  BentoCard(
                    padding: const EdgeInsets.all(AppDimens.xl),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.event_note_outlined,
                            size: 40,
                            color: AppColors.outline,
                          ),
                          const SizedBox(height: AppDimens.sm),
                          Text(
                            'No events managed yet',
                            style: AppTextStyles.titleLarge.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap Create Event to launch your first workshop or competition.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: events.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppDimens.md),
                    itemBuilder: (ctx, index) =>
                        _buildManagedEventCard(context, events[index]),
                  ),
                const SizedBox(height: AppDimens.xxl),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickOperationsRow(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 600;
        return GridView.count(
          crossAxisCount: isDesktop ? 4 : 2,
          crossAxisSpacing: AppDimens.md,
          mainAxisSpacing: AppDimens.md,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: isDesktop ? 1.6 : 1.4,
          children: [
            _buildOpCard(
              title: 'Create Event',
              subtitle: 'Form builder & dates',
              icon: Icons.add_circle_outline,
              color: AppColors.blue,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreateEventScreen()),
                );
              },
            ),
            _buildOpCard(
              title: 'Manage Members',
              subtitle: 'Roles & roster',
              icon: Icons.people_outline,
              color: AppColors.green,
              onTap: () => onNavigateTab?.call(3),
            ),
            _buildOpCard(
              title: 'View Responses',
              subtitle: 'Manage submissions',
              icon: Icons.analytics_outlined,
              color: AppColors.orangeDark,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const RegistrationResponsesScreen(),
                  ),
                );
              },
            ),
            _buildOpCard(
              title: 'Export Data',
              subtitle: 'Excel, CSV, PDF',
              icon: Icons.download_outlined,
              color: AppColors.red,
              onTap: () {
                ExportDataModal.show(
                  context: context,
                  registrations: EventController.instance.allRegistrations,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildOpCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
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
              color: color.withValues(alpha: 0.12),
              borderRadius: AppDimens.borderMd,
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.titleLarge.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManagedEventCard(BuildContext context, EventModel event) {
    return BentoCard(
      padding: const EdgeInsets.all(AppDimens.lg),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: AppDimens.borderMd,
              color: AppColors.surfaceContainerHigh,
            ),
            clipBehavior: Clip.antiAlias,
            child: event.bannerUrl.isNotEmpty
                ? Image.network(
                    event.bannerUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Center(
                      child: Icon(Icons.event, color: AppColors.blue),
                    ),
                  )
                : const Center(
                    child: Icon(Icons.event, color: AppColors.blue),
                  ),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge.success('Published'),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${event.registeredCount} / ${event.maxParticipants} Registrations • ${Formatters.formatDate(event.startDate)}',
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      RegistrationResponsesScreen(selectedEventId: event.id),
                ),
              );
            },
            child: const Text('Responses'),
          ),
        ],
      ),
    );
  }
}
