import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/event_model.dart';
import '../../state/auth_controller.dart';
import '../../state/event_controller.dart';
import 'event_registration_modal.dart';

class EventDetailsScreen extends StatefulWidget {
  final EventModel event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool _eligibilityExpanded = true;
  bool _rulesExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: EventController.instance,
      builder: (context, _) {
        final currentEvents = EventController.instance.allEvents;
        final event = currentEvents.firstWhere(
          (e) => e.id == widget.event.id,
          orElse: () => widget.event,
        );

        final user = AuthController.instance.currentUser;
        final isRegistered = EventController.instance.isUserRegistered(
          event.id,
          user.studentId,
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              // Scrollable Content
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Hero Section (442px)
                    _buildHeroSection(context, event),

                    // Main Content Container
                    Padding(
                      padding: const EdgeInsets.all(AppDimens.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 2. Meta Info Bento Grid (4 Cards)
                          _buildMetaInfoGrid(event),
                          const SizedBox(height: AppDimens.xl),

                          // 3. About the Event
                          _buildAboutSection(event),
                          const SizedBox(height: AppDimens.xl),

                          // 4. Prizes & Awards Bento
                          _buildPrizesSection(event),
                          const SizedBox(height: AppDimens.xl),

                          // 5. Rules & Eligibility Accordions
                          _buildRulesAndEligibility(event),
                          const SizedBox(height: AppDimens.xl),

                          // 6. Team & Organizer Card
                          _buildOrganizerCard(event),
                          const SizedBox(height: AppDimens.xl),

                          // 7. Timeline Section
                          _buildTimelineSection(event),
                          const SizedBox(height: AppDimens.xl),

                          // 8. Venue & Map Section
                          _buildVenueAndMap(event),
                          const SizedBox(height: AppDimens.xl),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 10. Sticky Bottom Action Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildStickyBottomBar(context, event, isRegistered),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroSection(BuildContext context, EventModel event) {
    final bannerUrl = event.bannerUrl.isNotEmpty
        ? event.bannerUrl
        : 'https://lh3.googleusercontent.com/aida-public/AB6AXuCfuPDl-qEa3KHYO-0Av5lYAg5i6RxUWTjAqDW-mMIUTW04xpPazPrVW1E5VmTlXch5hDVfxZCyXaiOXh10p3pS_6XHdfowC_a06tflAIjtYyY1ywz491SJlOHUEZxVqI4APiWyZ2tc-cJ2AXB-m1sF-A3TmiWbWh9Rwkso_-NWMitgeZ1Rjk38CRv7YUpgEgI1JMb9QmFXl0zkNSxCIwC-LGlsbhagHCp7DEGxsgH8O-quqQCQBcmS7Q';

    return SizedBox(
      height: 442,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Banner Image (Tappable for Full-Screen View)
          GestureDetector(
            onTap: () => _openFullScreenBanner(context, bannerUrl, event.title),
            child: Image.network(
              bannerUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: const Color(0xFF24389C),
                child: const Center(
                  child: Icon(Icons.event, size: 80, color: Colors.white24),
                ),
              ),
            ),
          ),

          // Gradient Fade Overlay
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.background,
                    AppColors.background.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // Floating Back Button Overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: AppDimens.md,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.surface.withValues(alpha: 0.85),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),

          // Bottom Hero Metadata
          Positioned(
            bottom: AppDimens.md,
            left: AppDimens.md,
            right: AppDimens.md,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                    border: Border.all(color: AppColors.blue.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    event.customCategory ?? event.category.name.toUpperCase(),
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.xs),

                // Event Title
                Text(
                  event.title,
                  style: AppTextStyles.displaySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 2),

                // Tagline / Subtitle
                Text(
                  event.tagline ?? 'Build. Innovate. Solve.',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openFullScreenBanner(BuildContext context, String imageUrl, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Zoomable & Pannable Fullscreen Image
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Center(
                      child: Icon(Icons.broken_image, color: Colors.white54, size: 64),
                    ),
                  ),
                ),
              ),

              // Top Bar with Close Button & Title
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaInfoGrid(EventModel event) {
    final dateStr = DateFormat('d MMM yyyy').format(event.startDate);
    final timeStr = event.timeString.isNotEmpty ? event.timeString : '10:00 AM - 6:00 PM';
    final venueStr = event.venue.isNotEmpty ? event.venue : 'Main Campus';
    final regStr = '${event.registeredCount} Registered';

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppDimens.sm,
      mainAxisSpacing: AppDimens.sm,
      childAspectRatio: 1.75,
      children: [
        _buildMetaCard(Icons.calendar_today_outlined, 'Date', dateStr),
        _buildMetaCard(Icons.schedule_outlined, 'Time', timeStr),
        _buildMetaCard(Icons.location_on_outlined, 'Venue', venueStr),
        _buildMetaCard(Icons.group_outlined, 'Participants', regStr),
      ],
    );
  }

  Widget _buildMetaCard(IconData icon, String label, String value) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.blue, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(EventModel event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About the Event',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimens.sm),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          padding: const EdgeInsets.all(AppDimens.md),
          child: Text(
            event.description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrizesSection(EventModel event) {
    final p1 = event.prizes.isNotEmpty ? event.prizes[0].amount : '₹25k';
    final p2 = event.prizes.length > 1 ? event.prizes[1].amount : '₹15k';
    final p3 = event.prizes.length > 2 ? event.prizes[2].amount : '₹10k';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prizes & Awards',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimens.sm),

        // 1st Place Card (Full Width Indigo)
        Container(
          width: double.infinity,
          height: 76,
          decoration: BoxDecoration(
            color: const Color(0xFF24389C),
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
          child: Stack(
            children: [
              // Trophy Watermark in top right
              Positioned(
                right: -8,
                top: -8,
                bottom: -8,
                child: Icon(
                  Icons.emoji_events,
                  size: 76,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
              // Centered Labels
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '1ST PLACE',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p1,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.sm),

        // 2nd Place Card (Full Width Surface)
        Container(
          width: double.infinity,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Stack(
            children: [
              // Medal Watermark in top right
              Positioned(
                right: -6,
                top: -6,
                bottom: -6,
                child: Icon(
                  Icons.military_tech,
                  size: 72,
                  color: AppColors.textSecondary.withValues(alpha: 0.08),
                ),
              ),
              // Centered Labels
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '2ND PLACE',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p2,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.sm),

        // 3rd Place Card (Full Width Surface)
        Container(
          width: double.infinity,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Stack(
            children: [
              // Medal Watermark in top right
              Positioned(
                right: -6,
                top: -6,
                bottom: -6,
                child: Icon(
                  Icons.military_tech,
                  size: 72,
                  color: AppColors.textSecondary.withValues(alpha: 0.08),
                ),
              ),
              // Centered Labels
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '3RD PLACE',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p3,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.sm),

        // Special Awards Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimens.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lightbulb_outline, color: AppColors.blue, size: 20),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Special Awards',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Best Innovation, Best UI/UX, and Best Beginner Hack.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRulesAndEligibility(EventModel event) {
    final eligibilityText = event.eligibility.isNotEmpty
        ? event.eligibility.join('\n')
        : 'Open to all undergraduate and postgraduate students. Participants must have a valid student ID. Teams must consist of 1 to 4 members from the same institution.';

    final rulesText = event.rules.isNotEmpty
        ? event.rules.join('\n')
        : 'All code must be written during the event. Use of open-source libraries is permitted. Submissions must include a GitHub repository link and demo.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rules & Eligibility',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimens.sm),

        // Accordion 1: Eligibility
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: ExpansionTile(
            initiallyExpanded: _eligibilityExpanded,
            onExpansionChanged: (v) => setState(() => _eligibilityExpanded = v),
            title: Text(
              'Eligibility Criteria',
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            childrenPadding: const EdgeInsets.all(AppDimens.md),
            children: [
              Text(
                eligibilityText,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.sm),

        // Accordion 2: Rules
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: ExpansionTile(
            initiallyExpanded: _rulesExpanded,
            onExpansionChanged: (v) => setState(() => _rulesExpanded = v),
            title: Text(
              'Competition Rules',
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            childrenPadding: const EdgeInsets.all(AppDimens.md),
            children: [
              Text(
                rulesText,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrganizerCard(EventModel event) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ORGANIZED BY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.blue.withValues(alpha: 0.15),
                child: Text(
                  event.organizerName.isNotEmpty ? event.organizerName.substring(0, 2).toUpperCase() : 'CC',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.blue),
                ),
              ),
              const SizedBox(width: AppDimens.md),
              Text(
                event.organizerName.isNotEmpty ? event.organizerName : 'Coding Club',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.outlineVariant),
          const Text('TEAM REQUIREMENTS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.groups, color: AppColors.blue, size: 20),
              const SizedBox(width: 8),
              Text('${event.teamMinSize} - ${event.teamMaxSize} Members per team', style: AppTextStyles.bodyMedium),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Team creation opens during registration.')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF24389C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Create Team', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Teammate discovery enabled in club chat.')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF24389C)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'Find Teammates',
                    style: TextStyle(color: Color(0xFF24389C), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection(EventModel event) {
    final regOpen = DateFormat('d MMM yyyy').format(
      event.startDate.isAfter(DateTime.now())
          ? DateTime.now().subtract(const Duration(days: 3))
          : event.startDate.subtract(const Duration(days: 7)),
    );
    final deadline = event.registrationDeadline != null
        ? DateFormat('d MMM yyyy').format(event.registrationDeadline!)
        : DateFormat('d MMM yyyy').format(event.startDate.subtract(const Duration(days: 2)));
    final eventDay = DateFormat('d MMM yyyy').format(event.startDate);
    final eventTitleDay = event.title.isNotEmpty
        ? (event.title.toLowerCase().contains('day') ? event.title : '${event.title} Day')
        : 'Event Day';

    final List<Map<String, dynamic>> items;
    if (event.timeline.isNotEmpty) {
      items = event.timeline.map((step) => {
        'title': step.title,
        'date': step.time,
        'isDone': step.isCompleted,
      }).toList();
    } else {
      items = [
        {'title': 'Registration Opens', 'date': regOpen, 'isDone': true},
        {'title': 'Idea Submission Deadline', 'date': deadline, 'isDone': false},
        {'title': eventTitleDay, 'date': eventDay, 'isDone': false},
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Timeline',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimens.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: AppDimens.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              return _buildTimelineItem(
                title: item['title'] as String,
                date: item['date'] as String,
                isDone: item['isDone'] as bool,
                isLast: index == items.length - 1,
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String date,
    required bool isDone,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left indicator column with Node Circle + Continuous Connecting Line
          SizedBox(
            width: 20,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isDone ? const Color(0xFF24389C) : AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDone ? const Color(0xFF24389C) : AppColors.outlineVariant,
                      width: 2,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: const Color(0xFF24389C).withValues(alpha: 0.25),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.md),

          // Right text column
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20.0),
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
                  Text(
                    date,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueAndMap(EventModel event) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Map preview container
          Container(
            height: 120,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFE8EEF5),
              image: DecorationImage(
                image: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBR2d5dOLEeCxaTP2DjO9JbxHBeKhMbIJTQ-Dqx4SJJKD_a9uKM8a6f8q8Ofv_4E0LwkAySNUy1kgXte8q1zq_yym2CLSIyqKYMYhwU-H7ntnKUXXW0fS4HYdb4nQfByNaJFRHHjP9ozbBnrO1ZQW7uWrIxy3vS3qzY5YWP5nc4AjmOm9LwqJ8G5Eax1I0AhhKs62Rgfe8MNO4aPZtimM1gsqkoIgnN87Bxp9eFnEGsV06-asqVERhnwg',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimens.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.venue.isNotEmpty ? event.venue : 'Main Auditorium',
                      style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Campus Center',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.near_me_outlined, color: Color(0xFF24389C)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Navigating to ${event.venue}...')),
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

  Widget _buildStickyBottomBar(BuildContext context, EventModel event, bool isRegistered) {
    final displayFee = event.entryFee > 0 ? '₹${event.entryFee.toStringAsFixed(0)}' : '₹0';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: AppDimens.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: const Border(top: BorderSide(color: AppColors.outlineVariant)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
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
                  displayFee,
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Entry Fee',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(width: AppDimens.md),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isRegistered
                    ? null
                    : () {
                        EventRegistrationModal.show(context: context, event: event);
                      },
                icon: Icon(
                  isRegistered ? Icons.check_circle : Icons.arrow_forward,
                  size: 18,
                ),
                label: Text(
                  isRegistered ? 'Registered ✓' : 'Proceed to Register',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF24389C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
