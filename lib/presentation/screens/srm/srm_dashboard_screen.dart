import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../shared/chips/app_chips.dart';
import '../../shared/headers/screen_header.dart';
import '../../shared/inputs/app_dropdown.dart';
import '../../shared/inputs/app_text_field.dart';
import '../../state/auth_controller.dart';
import '../../state/srm_controller.dart';

class SrmDashboardScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const SrmDashboardScreen({super.key, this.onNavigateTab});

  @override
  State<SrmDashboardScreen> createState() => _SrmDashboardScreenState();
}

class _SrmDashboardScreenState extends State<SrmDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SrmController.instance.loadDashboard();
    });
  }

  void _showCreateClubDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final otherCategoryController = TextEditingController();
    final searchStudentController = TextEditingController();
    String selectedCategory = 'technical';
    String? selectedLeaderId;
    String studentSearchQuery = '';

    final srmCtrl = SrmController.instance;
    final students = srmCtrl.availableStudents;

    if (students.isNotEmpty) {
      selectedLeaderId = students.first.id;
    }

    final pageMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final q = studentSearchQuery.trim().toLowerCase();
          final filteredStudents = students.where((s) {
            if (q.isEmpty) return true;
            final matchName = s.name.toLowerCase().contains(q);
            final matchEmail = s.email.toLowerCase().contains(q);
            final matchPhone = s.phone.toLowerCase().contains(q);
            final matchId = s.studentId.toLowerCase().contains(q);
            return matchName || matchEmail || matchPhone || matchId;
          }).toList();

          final selectedStudent = selectedLeaderId != null
              ? students.where((s) => s.id == selectedLeaderId).firstOrNull
              : null;

          return AlertDialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(borderRadius: AppDimens.borderLg),
            title: Text(
              'Provision New Club & Assign Leader',
              style: AppTextStyles.titleLarge.copyWith(color: AppColors.blue),
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'As an SRM Administrator, you can provision new student clubs and assign existing students as initial Club Leaders.',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppDimens.md),

                      // Club Name
                      AppTextField(
                        label: 'Club Name',
                        hint: 'e.g. AI & Machine Learning Society',
                        controller: nameController,
                        isRequired: true,
                        validator: (val) =>
                            val == null || val.trim().isEmpty ? 'Please enter club name' : null,
                      ),
                      const SizedBox(height: AppDimens.sm),

                      // Description
                      AppTextField(
                        label: 'Description',
                        hint: 'Focus area and mission of the club',
                        controller: descriptionController,
                        maxLines: 2,
                      ),
                      const SizedBox(height: AppDimens.sm),

                      // Category Dropdown
                      AppDropdown<String>(
                        label: 'Category',
                        hint: 'Select Category',
                        value: selectedCategory,
                        isRequired: true,
                        items: const [
                          DropdownMenuItem(value: 'technical', child: Text('Technical & Engineering')),
                          DropdownMenuItem(value: 'cultural', child: Text('Cultural & Arts')),
                          DropdownMenuItem(value: 'sports', child: Text('Sports & Athletics')),
                          DropdownMenuItem(value: 'academic', child: Text('Academic & Research')),
                          DropdownMenuItem(value: 'creative', child: Text('Creative & Media')),
                          DropdownMenuItem(value: 'others', child: Text('Others (Specify)')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedCategory = val);
                          }
                        },
                      ),

                      // If Others is selected, show specify category field
                      if (selectedCategory == 'others') ...[
                        const SizedBox(height: AppDimens.sm),
                        AppTextField(
                          label: 'Specify Category',
                          hint: 'e.g. Social Welfare, Entrepreneurship, Gaming',
                          controller: otherCategoryController,
                          isRequired: true,
                          prefixIcon: Icons.category_outlined,
                          validator: (val) {
                            if (selectedCategory == 'others' && (val == null || val.trim().isEmpty)) {
                              return 'Please specify the club category';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: AppDimens.md),

                      // Assign Existing Student as Club Leader
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Assign Initial Club Leader *',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (selectedStudent != null)
                            Flexible(
                              child: Text(
                                'Selected: ${selectedStudent.name}',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.greenDark,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Student Search Bar by Name, Email, or Phone Number
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: AppDimens.borderMd,
                          border: Border.all(color: AppColors.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, size: 18, color: AppColors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: searchStudentController,
                                decoration: const InputDecoration(
                                  hintText: 'Search by name, email, or phone...',
                                  hintStyle: TextStyle(fontSize: 12, color: AppColors.outline),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                                ),
                                style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
                                onChanged: (val) {
                                  setDialogState(() {
                                    studentSearchQuery = val;
                                  });
                                },
                              ),
                            ),
                            if (searchStudentController.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.close, size: 16, color: AppColors.outline),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  setDialogState(() {
                                    searchStudentController.clear();
                                    studentSearchQuery = '';
                                  });
                                },
                              ),
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () {
                                setDialogState(() {
                                  studentSearchQuery = searchStudentController.text;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.blue,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Search',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Filtered Student List
                      if (students.isEmpty)
                        Text(
                          'No registered students found in database.',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.red),
                        )
                      else if (filteredStudents.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'No student matching "$studentSearchQuery". Try another name, email, or phone.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      else ...[
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.outlineVariant),
                            borderRadius: AppDimens.borderMd,
                            color: AppColors.surfaceContainerLowest,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: filteredStudents.take(5).map((s) {
                              final isSelected = s.id == selectedLeaderId;
                              return InkWell(
                                onTap: () {
                                  setDialogState(() => selectedLeaderId = s.id);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  color: isSelected
                                      ? AppColors.blueLight
                                      : Colors.transparent,
                                  child: Row(
                                    children: [
                                      Icon(
                                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                        size: 18,
                                        color: isSelected ? AppColors.blue : AppColors.outline,
                                      ),
                                      const SizedBox(width: 8),
                                      CircleAvatar(
                                        radius: 14,
                                        backgroundColor: AppColors.blueLight,
                                        child: Text(
                                          s.name.isNotEmpty ? s.name[0].toUpperCase() : 'S',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.blue,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              s.name,
                                              style: AppTextStyles.bodyMedium.copyWith(
                                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                                color: AppColors.textPrimary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              '${s.email}${s.phone.isNotEmpty ? " • ${s.phone}" : ""}${s.studentId.isNotEmpty ? " • ${s.studentId}" : ""}',
                                              style: AppTextStyles.bodySmall.copyWith(
                                                color: AppColors.textSecondary,
                                                fontSize: 11,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.greenLight,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'Leader',
                                            style: AppTextStyles.labelMedium.copyWith(
                                              color: AppColors.greenDark,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        if (filteredStudents.length > 5)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Showing 5 of ${filteredStudents.length} students. Type to filter.',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: srmCtrl.isCreating
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        if (selectedLeaderId == null) {
                          pageMessenger.showSnackBar(
                            const SnackBar(content: Text('Please select an existing student as leader')),
                          );
                          return;
                        }

                        final categoryToSave = selectedCategory == 'others'
                            ? (otherCategoryController.text.trim().isNotEmpty
                                ? otherCategoryController.text.trim()
                                : 'others')
                            : selectedCategory;

                        try {
                          final success = await srmCtrl.createClub(
                            name: nameController.text.trim(),
                            description: descriptionController.text.trim(),
                            category: categoryToSave,
                            logoUrl: null,
                            leaderUserId: selectedLeaderId!,
                          );

                          if (dialogCtx.mounted) {
                            Navigator.of(dialogCtx).pop();
                          }

                          pageMessenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? (srmCtrl.successMessage ?? 'Club provisioned successfully!')
                                    : (srmCtrl.errorMessage ?? 'Failed to create club'),
                              ),
                              backgroundColor: success ? AppColors.green : AppColors.red,
                            ),
                          );
                        } catch (err) {
                          if (dialogCtx.mounted) {
                            Navigator.of(dialogCtx).pop();
                          }
                          pageMessenger.showSnackBar(
                            SnackBar(
                              content: Text('Error creating club: $err'),
                              backgroundColor: AppColors.red,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: AppColors.white,
                ),
                child: srmCtrl.isCreating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Text('Provision Club'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        AuthController.instance,
        SrmController.instance,
      ]),
      builder: (context, _) {
        final srmCtrl = SrmController.instance;
        final stats = srmCtrl.stats;
        final clubs = srmCtrl.clubs;

        return RefreshIndicator(
          onRefresh: () => srmCtrl.loadDashboard(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.marginMobile,
              vertical: AppDimens.lg,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome and Action Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: ScreenHeader(
                          title: 'SRM Administrator Portal',
                          subtitle: 'Campus Connect Overview & Club Governance',
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _showCreateClubDialog,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Create Club'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimens.lg,
                            vertical: AppDimens.md,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: AppDimens.borderMd),
                          elevation: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.lg),

                  // Stats Bento Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 700;
                      final crossAxisCount = isWide ? 4 : 2;

                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: AppDimens.md,
                        mainAxisSpacing: AppDimens.md,
                        childAspectRatio: isWide ? 1.5 : 1.3,
                        children: [
                          _buildStatCard(
                            title: 'Total Clubs',
                            value: '${stats.totalClubs}',
                            icon: Icons.groups_outlined,
                            color: AppColors.blue,
                            bgColor: AppColors.blueLight,
                          ),
                          _buildStatCard(
                            title: 'Active Clubs',
                            value: '${stats.activeClubs}',
                            icon: Icons.check_circle_outline,
                            color: AppColors.green,
                            bgColor: AppColors.greenLight,
                          ),
                          _buildStatCard(
                            title: 'Total Students',
                            value: '${stats.totalStudents}',
                            icon: Icons.school_outlined,
                            color: AppColors.orangeDark,
                            bgColor: AppColors.orangeLight,
                          ),
                          _buildStatCard(
                            title: 'Total Club Leaders',
                            value: '${stats.totalClubLeaders}',
                            icon: Icons.badge_outlined,
                            color: AppColors.blue,
                            bgColor: AppColors.blueLight,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppDimens.xl),

                  // Recently Created Clubs Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recently Created Clubs',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${clubs.length} Clubs in Supabase',
                        style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.md),

                  // Clubs List Container
                  if (srmCtrl.isLoading && clubs.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppDimens.xl),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (clubs.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(AppDimens.xl),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: AppDimens.borderLg,
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.groups_outlined, size: 48, color: AppColors.outline),
                            const SizedBox(height: AppDimens.sm),
                            Text(
                              'No clubs provisioned yet',
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: AppDimens.borderLg,
                        border: Border.all(color: AppColors.outlineVariant),
                        boxShadow: AppDimens.cardShadow,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: clubs.length,
                        separatorBuilder: (c, i) => const Divider(
                          height: 1,
                          color: AppColors.outlineVariant,
                        ),
                        itemBuilder: (context, index) {
                          final club = clubs[index];
                          return Padding(
                            padding: const EdgeInsets.all(AppDimens.md),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerLow,
                                    borderRadius: AppDimens.borderMd,
                                    border: Border.all(color: AppColors.outlineVariant),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Image.network(
                                    club.logoUrl.isNotEmpty
                                        ? club.logoUrl
                                        : 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=150',
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => const Icon(
                                      Icons.groups,
                                      color: AppColors.blue,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppDimens.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        club.name,
                                        style: AppTextStyles.headlineSmall.copyWith(
                                          color: AppColors.textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Leader: ${club.leaderName ?? "Unassigned"}${club.description.isNotEmpty ? " • ${club.description}" : ""}',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppDimens.sm),
                                StatusBadge.success(club.status.toUpperCase()),
                                IconButton(
                                  icon: const Icon(Icons.more_vert, color: AppColors.outline),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Managing ${club.name}')),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppDimens.borderLg,
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: AppDimens.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: AppDimens.borderSm,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
