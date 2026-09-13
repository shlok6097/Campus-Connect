import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/event_model.dart';
import '../../state/auth_controller.dart';
import '../../state/event_controller.dart';
import '../organizer/create_event_screen.dart';
import '../organizer/registration_responses_screen.dart';
import 'manage_event_overview_screen.dart';
import 'send_event_notification_screen.dart';

class ClubEventsScreen extends StatelessWidget {
  const ClubEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([EventController.instance, AuthController.instance]),
      builder: (context, _) {
        final user = AuthController.instance.currentUser;
        final clubEvents = EventController.instance.getClubPublishedEvents(
          clubName: user.clubName,
          clubId: user.clubId,
          userId: user.id,
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          body: RefreshIndicator(
            onRefresh: () => EventController.instance.loadEvents(),
            color: const Color(0xFF24389C),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppDimens.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Events List or Empty State
                  if (clubEvents.isEmpty)
                    _buildEmptyState(context)
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: clubEvents.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppDimens.md),
                      itemBuilder: (context, index) {
                        final event = clubEvents[index];
                        return _buildEventCard(context, event);
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
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
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
            child: const Icon(Icons.event_busy, size: 48, color: Color(0xFF24389C)),
          ),
          const SizedBox(height: AppDimens.md),
          Text(
            'No Published Events Yet',
            style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Create and publish events for your club to manage registrations, responses, and participant notifications.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimens.lg),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CreateEventScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Create New Event'),
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

  Widget _buildEventCard(BuildContext context, EventModel event) {
    final dateStr = DateFormat('d MMM yyyy').format(event.startDate);
    final timeStr = event.timeString.isNotEmpty ? event.timeString : '10:00 AM - 4:00 PM';
    final venueStr = event.venue.isNotEmpty ? event.venue : 'Main Campus';
    final feeStr = event.entryFee > 0 ? '₹${event.entryFee.toStringAsFixed(0)}' : 'Free';
    final categoryLabel = event.customCategory ?? event.category.name.toUpperCase();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image & Published Pill
          SizedBox(
            height: 140,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                event.bannerUrl.isNotEmpty
                    ? Image.network(
                        event.bannerUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: const Color(0xFF24389C),
                          child: const Center(
                            child: Icon(Icons.event, color: Colors.white38, size: 40),
                          ),
                        ),
                      )
                    : Container(
                        color: const Color(0xFF24389C),
                        child: const Center(
                          child: Icon(Icons.event, color: Colors.white38, size: 40),
                        ),
                      ),
                // Published Badge
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.outlineVariant),
                      boxShadow: const [
                        BoxShadow(color: Color(0x14000000), blurRadius: 4),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF008744),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Published',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Event Card Content
          Padding(
            padding: const EdgeInsets.all(AppDimens.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Tag & Quick Action Icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDEE0FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          categoryLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF24389C),
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Edit Event',
                          icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CreateEventScreen(eventToEdit: event),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          tooltip: 'View Responses',
                          icon: const Icon(Icons.list_alt, size: 18, color: AppColors.textSecondary),
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => RegistrationResponsesScreen(initialEvent: event),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          tooltip: 'Send Notification',
                          icon: const Icon(Icons.campaign_outlined, size: 18, color: AppColors.textSecondary),
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SendEventNotificationScreen(event: event),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Event Title
                Text(
                  event.title,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Meta Details (Date, Time, Venue)
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        dateStr,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.schedule_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        timeStr,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        venueStr,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Dashed Divider & Registrations / Fee Row
                Container(
                  padding: const EdgeInsets.only(top: 8),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.outlineVariant, style: BorderStyle.solid),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Registrations',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                          Text(
                            '${event.registeredCount}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Entry Fee',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                          Text(
                            feeStr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: event.entryFee > 0 ? const Color(0xFF24389C) : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Manage Event CTA Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ManageEventOverviewScreen(event: event),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF24389C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Manage Event',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
