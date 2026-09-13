import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/export_service.dart';
import '../../../data/models/event_model.dart';
import '../../../data/models/registration_model.dart';
import '../../state/event_controller.dart';
import 'export_data_modal.dart';

class RegistrationResponsesScreen extends StatefulWidget {
  final String? selectedEventId;
  final EventModel? initialEvent;
  final bool isEmbedded;

  const RegistrationResponsesScreen({
    super.key,
    this.selectedEventId,
    this.initialEvent,
    this.isEmbedded = false,
  });

  @override
  State<RegistrationResponsesScreen> createState() =>
      _RegistrationResponsesScreenState();
}

class _RegistrationResponsesScreenState
    extends State<RegistrationResponsesScreen> {
  final _searchController = TextEditingController();
  int _selectedFilterIndex = 0; // 0: All, 1: Confirmed, 2: Pending, 3: Checked In
  final Set<String> _checkedInIds = {};

  final List<String> _filterTabs = ['All', 'Confirmed', 'Pending', 'Checked In'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _exportFormat(ExportFormat format, List<RegistrationModel> list) async {
    if (list.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No registrations to export!')),
      );
      return;
    }

    try {
      await ExportService.exportAndShare(
        registrations: list,
        format: format,
        eventTitle: 'Campus_Connect_Registrations',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${format.name.toUpperCase()} file generated & shared successfully!'),
          backgroundColor: AppColors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e'), backgroundColor: AppColors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: EventController.instance,
      builder: (context, _) {
        final targetEventId = widget.initialEvent?.id ?? widget.selectedEventId;
        final allRegs = targetEventId != null
            ? EventController.instance.getRegistrationsForEvent(targetEventId)
            : EventController.instance.allRegistrations;

        final query = _searchController.text.toLowerCase().trim();
        final filteredRegs = allRegs.where((r) {
          final matchesQuery = query.isEmpty ||
              r.studentName.toLowerCase().contains(query) ||
              r.studentUSN.toLowerCase().contains(query) ||
              r.branch.toLowerCase().contains(query) ||
              r.eventTitle.toLowerCase().contains(query);

          if (!matchesQuery) return false;

          final isCheckedIn = _checkedInIds.contains(r.id);

          if (_selectedFilterIndex == 1) {
            return (r.status == RegistrationStatus.confirmed || r.paymentStatus == 'verified') && !isCheckedIn;
          }
          if (_selectedFilterIndex == 2) {
            return r.status == RegistrationStatus.waitlisted || r.paymentStatus == 'pending';
          }
          if (_selectedFilterIndex == 3) {
            return isCheckedIn;
          }
          return true;
        }).toList();

        final activeEventTitle = widget.initialEvent?.title ??
            (allRegs.isNotEmpty ? allRegs.first.eventTitle : 'All Events');

        final content = SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header with Event Title & Total Count (Stitch 61ca7072b9f44e09a380f6ea41e9fb7b)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      activeEventTitle,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF24389C),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF24389C).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                    ),
                    child: Text(
                      '${allRegs.length} Total',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: const Color(0xFF24389C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.md),

                // 2. Search & Filter Controls
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Search student name or USN (e.g. 1MS22CS001)...',
                      prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.sm),

                // Export row (CSV, Excel, PDF Report)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Text(
                        'EXPORT: ',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      _buildExportChip(
                        icon: Icons.description,
                        label: 'CSV',
                        onTap: () => _exportFormat(ExportFormat.csv, filteredRegs),
                      ),
                      const SizedBox(width: 6),
                      _buildExportChip(
                        icon: Icons.table_view,
                        label: 'Excel',
                        onTap: () => _exportFormat(ExportFormat.excel, filteredRegs),
                      ),
                      const SizedBox(width: 6),
                      _buildExportChip(
                        icon: Icons.picture_as_pdf,
                        label: 'PDF Report',
                        onTap: () => _exportFormat(ExportFormat.pdf, filteredRegs),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.md),

                // 3. Filter Tabs (All, Confirmed, Pending, Checked In)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filterTabs.asMap().entries.map((entry) {
                      final isSelected = _selectedFilterIndex == entry.key;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => setState(() => _selectedFilterIndex = entry.key),
                          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.blue : AppColors.surface,
                              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                              border: Border.all(
                                color: isSelected ? AppColors.blue : AppColors.outlineVariant,
                              ),
                            ),
                            child: Text(
                              entry.value,
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: AppDimens.lg),

                // 4. Attendee Response Cards List
                if (filteredRegs.isEmpty) ...[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.xxl),
                      child: Column(
                        children: [
                          Icon(Icons.inbox, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.4)),
                          const SizedBox(height: AppDimens.sm),
                          Text('No responses found', style: AppTextStyles.titleMedium),
                          const SizedBox(height: 4),
                          Text('Try searching with a different keyword or filter.', style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  ...filteredRegs.map((reg) {
                    final isCheckedIn = _checkedInIds.contains(reg.id);
                    return _buildAttendeeCard(reg, isCheckedIn);
                  }),
                ],
              ],
            ),
          );

        if (widget.isEmbedded) {
          return content;
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0.5,
            iconTheme: const IconThemeData(color: Color(0xFF24389C)),
            title: Text(
              activeEventTitle,
              style: const TextStyle(
                color: Color(0xFF24389C),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.file_download_outlined, color: Color(0xFF24389C)),
                tooltip: 'Export Manager',
                onPressed: () {
                  ExportDataModal.show(
                    context: context,
                    registrations: filteredRegs,
                  );
                },
              ),
            ],
          ),
          body: content,
        );
      },
    );
  }

  Widget _buildExportChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.blue),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendeeCard(RegistrationModel reg, bool isCheckedIn) {
    final isConfirmed = reg.status == RegistrationStatus.confirmed && !isCheckedIn;
    final isPending = reg.status == RegistrationStatus.pending && !isCheckedIn;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.md),
      padding: const EdgeInsets.all(AppDimens.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top: Student Name, USN, Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reg.studentName,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    reg.studentUSN,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (isCheckedIn) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.how_to_reg, size: 14, color: AppColors.blue),
                      SizedBox(width: 4),
                      Text('Checked In', style: TextStyle(color: AppColors.blue, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ] else if (isConfirmed) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF008744).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 14, color: Color(0xFF008744)),
                      SizedBox(width: 4),
                      Text('Confirmed', style: TextStyle(color: Color(0xFF008744), fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.pending, size: 14, color: AppColors.textSecondary),
                      SizedBox(width: 4),
                      Text('Pending', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppDimens.sm),
          const Divider(height: 16, color: AppColors.outlineVariant),

          // Middle: Branch & Semester, Contact Details
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('BRANCH & SEMESTER', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                    const SizedBox(height: 2),
                    Text('${reg.branch} | ${reg.semester}th Sem', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CONTACT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                    const SizedBox(height: 2),
                    Text(reg.studentEmail, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
                    if (reg.studentPhone.isNotEmpty)
                      Text(reg.studentPhone, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sm),

          // Custom Responses Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimens.sm),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CUSTOM RESPONSES', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 16,
                  runSpacing: 6,
                  children: [
                    if (reg.customResponses.isNotEmpty)
                      ...reg.customResponses.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.key, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                            Text('${entry.value}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        );
                      })
                    else ...[
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('T-SHIRT SIZE', style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                          Text('Medium', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DIETARY', style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                          Text('Vegetarian', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],

                    // Payment Status in Custom Responses
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('PAYMENT', style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              reg.amount > 0 ? (reg.paymentStatus == 'verified' ? 'Verified' : 'Pending') : 'Free',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: reg.amount > 0
                                    ? (reg.paymentStatus == 'verified' ? const Color(0xFF008744) : const Color(0xFF8F4700))
                                    : AppColors.blue,
                              ),
                            ),
                            if (reg.amount > 0) ...[
                              const SizedBox(width: 4),
                              Text('(₹${reg.amount.toStringAsFixed(0)})', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.md),

          // Bottom Actions on Card
          Row(
            children: [
              if (isPending) ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      EventController.instance.updateRegistrationStatus(reg.id, RegistrationStatus.confirmed);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${reg.studentName} confirmed!'), backgroundColor: AppColors.green),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0057E7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Approve'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      EventController.instance.updateRegistrationStatus(reg.id, RegistrationStatus.rejected);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${reg.studentName} rejected.'), backgroundColor: AppColors.red),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.red),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Reject', style: TextStyle(color: AppColors.red)),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: isCheckedIn
                        ? null
                        : () {
                            setState(() => _checkedInIds.add(reg.id));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${reg.studentName} checked in!'), backgroundColor: AppColors.green),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF008744),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(isCheckedIn ? 'Checked In' : 'Check In'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showStudentProfileModal(context, reg);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.outlineVariant),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('View Full Profile', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showStudentProfileModal(BuildContext context, RegistrationModel reg) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(AppDimens.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(reg.studentName, style: AppTextStyles.titleLarge),
              Text(reg.studentUSN, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.blue)),
              const Divider(height: 24),
              Text('Event: ${reg.eventTitle}', style: AppTextStyles.bodyMedium),
              Text('Branch: ${reg.branch} • Semester ${reg.semester}', style: AppTextStyles.bodyMedium),
              Text('Email: ${reg.studentEmail}', style: AppTextStyles.bodyMedium),
              Text('Phone: ${reg.studentPhone}', style: AppTextStyles.bodyMedium),
              if (reg.paymentReference != null)
                Text('Payment Ref: ${reg.paymentReference}', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.green)),
              const SizedBox(height: AppDimens.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
