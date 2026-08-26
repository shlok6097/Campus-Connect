import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/registration_model.dart';
import '../../shared/cards/bento_card.dart';
import '../../shared/chips/app_chips.dart';
import '../../shared/inputs/app_search_bar.dart';
import '../../state/event_controller.dart';
import 'export_data_modal.dart';

class RegistrationResponsesScreen extends StatefulWidget {
  final String? selectedEventId;

  const RegistrationResponsesScreen({super.key, this.selectedEventId});

  @override
  State<RegistrationResponsesScreen> createState() =>
      _RegistrationResponsesScreenState();
}

class _RegistrationResponsesScreenState
    extends State<RegistrationResponsesScreen> {
  final _searchController = TextEditingController();
  int _selectedFilterIndex = 0; // 0: All, 1: Confirmed, 2: Pending

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
        final allRegs = widget.selectedEventId != null
            ? EventController.instance.getRegistrationsForEvent(
                widget.selectedEventId!,
              )
            : EventController.instance.allRegistrations;

        final query = _searchController.text.toLowerCase();
        final filteredRegs = allRegs.where((r) {
          final matchesQuery =
              query.isEmpty ||
              r.studentName.toLowerCase().contains(query) ||
              r.studentUSN.toLowerCase().contains(query) ||
              r.branch.toLowerCase().contains(query) ||
              r.eventTitle.toLowerCase().contains(query);

          if (_selectedFilterIndex == 1)
            return matchesQuery && r.status == RegistrationStatus.confirmed;
          if (_selectedFilterIndex == 2)
            return matchesQuery && r.status == RegistrationStatus.pending;
          return matchesQuery;
        }).toList();

        final confirmedCount = allRegs
            .where((r) => r.status == RegistrationStatus.confirmed)
            .length;
        final pendingCount = allRegs
            .where((r) => r.status == RegistrationStatus.pending)
            .length;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            title: Text(
              'Registration Responses',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.blue,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.download, color: AppColors.blue),
                tooltip: 'Export Data',
                onPressed: () {
                  ExportDataModal.show(
                    context: context,
                    registrations: filteredRegs,
                  );
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              ExportDataModal.show(
                context: context,
                registrations: filteredRegs,
              );
            },
            backgroundColor: AppColors.green,
            foregroundColor: AppColors.white,
            icon: const Icon(Icons.file_download),
            label: const Text('Export Data'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.marginMobile),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  AppSearchBar(
                    hint: 'Search by student name, USN, or department...',
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppDimens.md),

                  // Filter Tabs
                  Row(
                    children: [
                      _buildFilterChip('All (${allRegs.length})', 0),
                      const SizedBox(width: AppDimens.sm),
                      _buildFilterChip('Confirmed ($confirmedCount)', 1),
                      const SizedBox(width: AppDimens.sm),
                      _buildFilterChip('Pending ($pendingCount)', 2),
                    ],
                  ),
                  const SizedBox(height: AppDimens.lg),

                  // Response Cards List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredRegs.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppDimens.md),
                    itemBuilder: (ctx, index) =>
                        _buildResponseCard(filteredRegs[index]),
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

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedFilterIndex == index;
    return Material(
      color: isSelected ? AppColors.blue : AppColors.white,
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected ? AppColors.blue : AppColors.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: () => setState(() => _selectedFilterIndex = index),
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.md,
            vertical: AppDimens.sm,
          ),
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: isSelected ? AppColors.white : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResponseCard(RegistrationModel reg) {
    final isConfirmed = reg.status == RegistrationStatus.confirmed;

    return BentoCard(
      padding: const EdgeInsets.all(AppDimens.lg),
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
                    reg.studentName,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${reg.studentUSN} • ${reg.branch} • Sem ${reg.semester}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              isConfirmed
                  ? StatusBadge.success('Confirmed')
                  : StatusBadge.warning('Pending'),
            ],
          ),
          const SizedBox(height: AppDimens.sm),
          Row(
            children: [
              const Icon(
                Icons.email_outlined,
                size: 14,
                color: AppColors.outline,
              ),
              const SizedBox(width: 4),
              Text(reg.studentEmail, style: AppTextStyles.bodySmall),
              const SizedBox(width: 12),
              const Icon(
                Icons.phone_outlined,
                size: 14,
                color: AppColors.outline,
              ),
              const SizedBox(width: 4),
              Text(reg.studentPhone, style: AppTextStyles.bodySmall),
            ],
          ),
          if (reg.customResponses.isNotEmpty) ...[
            const Divider(height: AppDimens.lg),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: reg.customResponses.entries.map((e) {
                return Text(
                  '${e.key}: ${e.value}',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: AppDimens.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Registered ${Formatters.formatDate(reg.registrationDate)}',
                style: AppTextStyles.labelMedium.copyWith(fontSize: 11),
              ),
              Row(
                children: [
                  if (!isConfirmed)
                    TextButton(
                      onPressed: () {
                        EventController.instance.updateRegistrationStatus(
                          reg.id,
                          RegistrationStatus.confirmed,
                        );
                      },
                      child: const Text(
                        'Approve',
                        style: TextStyle(color: AppColors.green),
                      ),
                    ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Registration pass for ${reg.studentName}: ${reg.id}',
                          ),
                        ),
                      );
                    },
                    child: const Text('View Pass'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
