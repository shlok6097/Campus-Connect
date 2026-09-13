import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/event_model.dart';
import '../../../data/models/registration_model.dart';
import '../../state/event_controller.dart';
import '../organizer/create_event_screen.dart';
import '../organizer/registration_responses_screen.dart';
import 'send_event_notification_screen.dart';

class ManageEventOverviewScreen extends StatefulWidget {
  final EventModel event;
  final int initialTabIndex;

  const ManageEventOverviewScreen({
    super.key,
    required this.event,
    this.initialTabIndex = 0,
  });

  @override
  State<ManageEventOverviewScreen> createState() => _ManageEventOverviewScreenState();
}

class _ManageEventOverviewScreenState extends State<ManageEventOverviewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<EventUpdateModel> _updates = [];
  bool _isLoadingUpdates = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _loadUpdates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUpdates() async {
    setState(() => _isLoadingUpdates = true);
    final fetched = await EventController.instance.fetchEventUpdates(widget.event.id);
    if (!mounted) return;
    setState(() {
      _updates = fetched;
      _isLoadingUpdates = false;
    });
  }

  void _showPostUpdateModal() {
    final titleController = TextEditingController();
    final msgController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isPosting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(modalCtx).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(AppDimens.lg),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Post Event Update',
                          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(modalCtx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.md),
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Update Title *',
                        hintText: 'e.g., Venue changed to Main Auditorium',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
                    ),
                    const SizedBox(height: AppDimens.md),
                    TextFormField(
                      controller: msgController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Update Details (Optional)',
                        hintText: 'Provide additional information for participants...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: AppDimens.lg),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isPosting
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                setModalState(() => isPosting = true);

                                final newUpdate = EventUpdateModel(
                                  id: 'UPD-${DateTime.now().millisecondsSinceEpoch}',
                                  eventId: widget.event.id,
                                  title: titleController.text.trim(),
                                  message: msgController.text.trim(),
                                  createdAt: DateTime.now(),
                                );

                                await EventController.instance.createEventUpdate(newUpdate);
                                if (!mounted) return;
                                Navigator.of(modalCtx).pop();
                                _loadUpdates();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Event update posted successfully!'),
                                    backgroundColor: Color(0xFF008744),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF24389C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isPosting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Post Update', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: EventController.instance,
      builder: (context, _) {
        final currentEvent = EventController.instance.allEvents.firstWhere(
          (e) => e.id == widget.event.id,
          orElse: () => widget.event,
        );

        final allRegs = EventController.instance.getRegistrationsForEvent(currentEvent.id);
        final confirmedCount = allRegs.where((r) => r.status == RegistrationStatus.confirmed).length;
        final pendingCount = allRegs.where((r) => r.status == RegistrationStatus.waitlisted || r.paymentStatus == 'pending').length;
        final totalCollected = confirmedCount * currentEvent.entryFee;
        final collectedStr = currentEvent.entryFee > 0
            ? (totalCollected >= 1000 ? '₹${(totalCollected / 1000).toStringAsFixed(1)}k' : '₹${totalCollected.toStringAsFixed(0)}')
            : '₹0';

        final maxCapacity = currentEvent.maxParticipants > 0 ? currentEvent.maxParticipants : 100;
        final capacityPercent = (currentEvent.registeredCount / maxCapacity).clamp(0.0, 1.0);
        final percentText = '${(capacityPercent * 100).toInt()}% Full';

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0.5,
            iconTheme: const IconThemeData(color: Color(0xFF24389C)),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    currentEvent.title,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: const Color(0xFF24389C),
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF24389C).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF24389C).withValues(alpha: 0.2)),
                  ),
                  child: const Text(
                    'Published',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF24389C),
                    ),
                  ),
                ),
              ],
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF24389C),
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: const Color(0xFF24389C),
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Responses'),
                Tab(text: 'Updates'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Overview
              _buildOverviewTab(
                context,
                currentEvent,
                confirmedCount: confirmedCount,
                pendingCount: pendingCount,
                collectedStr: collectedStr,
                maxCapacity: maxCapacity,
                capacityPercent: capacityPercent,
                percentText: percentText,
              ),

              // Tab 2: Responses
              RegistrationResponsesScreen(
                initialEvent: currentEvent,
                isEmbedded: true,
              ),

              // Tab 3: Updates
              _buildUpdatesTab(context, currentEvent),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    EventModel event, {
    required int confirmedCount,
    required int pendingCount,
    required String collectedStr,
    required int maxCapacity,
    required double capacityPercent,
    required String percentText,
  }) {
    return RefreshIndicator(
      onRefresh: () async {
        await EventController.instance.loadEvents();
        await _loadUpdates();
      },
      color: const Color(0xFF24389C),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 4-Stat Bento Grid (Stitch be20520fc9734e6dad1b01fff908ca13)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppDimens.sm,
              mainAxisSpacing: AppDimens.sm,
              childAspectRatio: 1.8,
              children: [
                _buildStatTile(
                  label: 'REGISTRATIONS',
                  value: '${event.registeredCount}',
                  valueColor: AppColors.textPrimary,
                ),
                _buildStatTile(
                  label: 'CONFIRMED',
                  value: '$confirmedCount',
                  valueColor: const Color(0xFF008744),
                  icon: Icons.check_circle,
                  iconColor: const Color(0xFF008744),
                ),
                _buildStatTile(
                  label: 'PENDING',
                  value: '$pendingCount',
                  valueColor: const Color(0xFF8F4700),
                  icon: Icons.pending,
                  iconColor: const Color(0xFF8F4700),
                ),
                _buildStatTile(
                  label: 'COLLECTED',
                  value: collectedStr,
                  valueColor: AppColors.textPrimary,
                  watermarkIcon: Icons.payments,
                ),
              ],
            ),
            const SizedBox(height: AppDimens.md),

            // Capacity Progress Card
            Container(
              padding: const EdgeInsets.all(AppDimens.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Capacity',
                            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Total seats filled',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${event.registeredCount}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF24389C),
                            ),
                          ),
                          Text(
                            ' / $maxCapacity',
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: capacityPercent,
                      minHeight: 10,
                      backgroundColor: const Color(0xFFE5E2E1),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF24389C)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      percentText,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.md),

            // Quick Actions Card (Stitch be20520fc9734e6dad1b01fff908ca13)
            Container(
              padding: const EdgeInsets.all(AppDimens.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CreateEventScreen(eventToEdit: event),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit Event'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF24389C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SendEventNotificationScreen(event: event),
                              ),
                            );
                          },
                          icon: const Icon(Icons.notifications_outlined, size: 18, color: Color(0xFF24389C)),
                          label: const Text(
                            'Send Notification',
                            style: TextStyle(color: Color(0xFF24389C), fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.outlineVariant),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimens.sm),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _tabController.animateTo(1),
                          icon: const Icon(Icons.group_outlined, size: 18, color: Color(0xFF24389C)),
                          label: const Text(
                            'View Responses',
                            style: TextStyle(color: Color(0xFF24389C), fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.outlineVariant),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.md),

            // Recent Updates Card (Stitch be20520fc9734e6dad1b01fff908ca13)
            Container(
              padding: const EdgeInsets.all(AppDimens.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Updates',
                        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        tooltip: 'Add Update',
                        icon: const Icon(Icons.add_circle_outline, color: Color(0xFF24389C)),
                        onPressed: _showPostUpdateModal,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (_isLoadingUpdates)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else if (_updates.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Center(
                        child: Text(
                          'No recent updates posted for this event.',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _updates.length > 3 ? 3 : _updates.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, idx) {
                        final update = _updates[idx];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.only(top: 4, right: 10),
                              decoration: const BoxDecoration(
                                color: Color(0xFF24389C),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    update.title,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                  if (update.message.isNotEmpty)
                                    Text(
                                      update.message,
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _showPostUpdateModal,
                      icon: const Icon(Icons.add_circle, size: 16, color: Color(0xFF24389C)),
                      label: const Text(
                        'Post Update',
                        style: TextStyle(color: Color(0xFF24389C), fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF24389C)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile({
    required String label,
    required String value,
    required Color valueColor,
    IconData? icon,
    Color? iconColor,
    IconData? watermarkIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Stack(
        children: [
          if (watermarkIcon != null)
            Positioned(
              right: -8,
              top: -8,
              child: Icon(
                watermarkIcon,
                size: 52,
                color: const Color(0xFF24389C).withValues(alpha: 0.08),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 14, color: iconColor ?? valueColor),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: iconColor ?? AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpdatesTab(BuildContext context, EventModel event) {
    return RefreshIndicator(
      onRefresh: _loadUpdates,
      color: const Color(0xFF24389C),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Event Updates & Announcements',
                        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Public notices posted for ${event.title}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _showPostUpdateModal,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Post Update'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF24389C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.md),
            const Divider(color: AppColors.outlineVariant, height: 1),
            const SizedBox(height: AppDimens.md),

            if (_isLoadingUpdates)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
            else if (_updates.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.campaign_outlined, size: 48, color: AppColors.textSecondary),
                    const SizedBox(height: 8),
                    const Text('No updates posted yet', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text(
                      'Post announcements regarding schedules, venue changes, or reminders.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _updates.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppDimens.sm),
                itemBuilder: (context, idx) {
                  final update = _updates[idx];
                  return Container(
                    padding: const EdgeInsets.all(AppDimens.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF24389C).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.campaign, size: 20, color: Color(0xFF24389C)),
                        ),
                        const SizedBox(width: AppDimens.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                update.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              if (update.message.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  update.message,
                                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                ),
                              ],
                              const SizedBox(height: 6),
                              Text(
                                '${update.createdAt.day}/${update.createdAt.month}/${update.createdAt.year} • ${update.createdAt.hour}:${update.createdAt.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.red, size: 18),
                          onPressed: () async {
                            await EventController.instance.deleteEventUpdate(update.id);
                            _loadUpdates();
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
