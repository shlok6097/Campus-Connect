import 'package:flutter/material.dart';
import '../../../core/services/export_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/registration_model.dart';
import '../../shared/buttons/primary_button.dart';
import '../../shared/cards/bento_card.dart';
import '../../shared/feedback/custom_bottom_sheet.dart';

class ExportDataModal {
  ExportDataModal._();

  static void show({
    required BuildContext context,
    required List<RegistrationModel> registrations,
    String eventTitle = 'Campus_Connect_Registrations',
  }) {
    CustomBottomSheet.show(
      context: context,
      title: 'Export Registrations',
      subtitle: 'Choose format to generate and download attendee responses',
      content: _ExportModalContent(
        registrations: registrations,
        eventTitle: eventTitle,
      ),
    );
  }
}

class _ExportModalContent extends StatefulWidget {
  final List<RegistrationModel> registrations;
  final String eventTitle;

  const _ExportModalContent({
    required this.registrations,
    required this.eventTitle,
  });

  @override
  State<_ExportModalContent> createState() => _ExportModalContentState();
}

class _ExportModalContentState extends State<_ExportModalContent> {
  ExportFormat _selectedFormat = ExportFormat.excel;
  bool _isExporting = false;

  void _handleExport() async {
    setState(() => _isExporting = true);
    try {
      await ExportService.exportAndShare(
        registrations: widget.registrations,
        format: _selectedFormat,
        eventTitle: widget.eventTitle,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported ${widget.registrations.length} records successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total Records: ${widget.registrations.length} Responses',
          style: AppTextStyles.labelMedium.copyWith(color: AppColors.blue, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppDimens.md),

        // Format Selection Bento Cards
        _buildFormatOption(
          format: ExportFormat.excel,
          title: 'Excel Spreadsheet (.xlsx)',
          subtitle: 'Formatted workbook with styled header row and auto-fitted columns',
          icon: Icons.table_chart_outlined,
          iconColor: AppColors.greenDark,
        ),
        const SizedBox(height: AppDimens.sm),
        _buildFormatOption(
          format: ExportFormat.csv,
          title: 'Comma Separated Values (.csv)',
          subtitle: 'Standard raw tabular format compatible with all databases',
          icon: Icons.grid_on_outlined,
          iconColor: AppColors.blue,
        ),
        const SizedBox(height: AppDimens.sm),
        _buildFormatOption(
          format: ExportFormat.pdf,
          title: 'Executive PDF Report (.pdf)',
          subtitle: 'Styled landscape document with summary counts and header logo',
          icon: Icons.picture_as_pdf_outlined,
          iconColor: AppColors.red,
        ),
        const SizedBox(height: AppDimens.xl),

        PrimaryButton(
          label: _isExporting ? 'Generating...' : 'Generate & Download',
          icon: Icons.download,
          backgroundColor: AppColors.green,
          isLoading: _isExporting,
          onPressed: _handleExport,
        ),
      ],
    );
  }

  Widget _buildFormatOption({
    required ExportFormat format,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    final isSelected = _selectedFormat == format;

    return BentoCard(
      onTap: () => setState(() => _selectedFormat = format),
      padding: const EdgeInsets.all(AppDimens.md),
      backgroundColor: isSelected ? AppColors.blueLight : AppColors.white,
      border: Border.all(
        color: isSelected ? AppColors.blue : AppColors.outlineVariant,
        width: isSelected ? 1.5 : 1.0,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: AppDimens.borderMd,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: isSelected ? AppColors.blue : AppColors.outline,
          ),
        ],
      ),
    );
  }
}
