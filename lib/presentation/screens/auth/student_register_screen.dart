import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../shared/buttons/primary_button.dart';
import '../../shared/inputs/app_dropdown.dart';
import '../../shared/inputs/app_text_field.dart';
import '../../state/auth_controller.dart';
import '../student/student_shell_screen.dart';

class StudentRegisterScreen extends StatefulWidget {
  const StudentRegisterScreen({super.key});

  @override
  State<StudentRegisterScreen> createState() => _StudentRegisterScreenState();
}

class _StudentRegisterScreenState extends State<StudentRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otherBranchController = TextEditingController();

  String? _selectedBranch;
  int? _selectedEndingYear;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final List<String> _branches = [
    'CSE',
    'ISE',
    'AIML (AIDS)',
    'MECH',
    'ECE',
    'EEE',
    'CIVIL',
    'ARCH',
    'Others',
  ];

  final List<int> _endingYears = [
    2024,
    2025,
    2026,
    2027,
    2028,
    2029,
    2030,
    2031,
    2032,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otherBranchController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;
    if (_selectedBranch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your branch')),
      );
      return;
    }
    if (_selectedBranch == 'Others' &&
        _otherBranchController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please specify your branch')),
      );
      return;
    }
    if (_selectedEndingYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your ending year')),
      );
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    final branch = _selectedBranch == 'Others'
        ? _otherBranchController.text.trim()
        : _selectedBranch!;

    final auth = AuthController.instance;
    final success = await auth.registerStudent(
      name: _nameController.text.trim(),
      studentId: _studentIdController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      branch: branch,
      endingYear: _selectedEndingYear!,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Student account registered! Welcome to Campus Connect.',
          ),
          backgroundColor: AppColors.green,
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const StudentShellScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.blue),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.marginMobile,
              vertical: AppDimens.sm,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: AnimatedBuilder(
                animation: AuthController.instance,
                builder: (context, _) {
                  final auth = AuthController.instance;

                  return Container(
                    padding: const EdgeInsets.all(AppDimens.lg),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: AppDimens.borderXl,
                      border: Border.all(color: AppColors.outlineVariant),
                      boxShadow: AppDimens.cardShadow,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header
                          Text(
                            'Join Campus Connect',
                            style: AppTextStyles.displayLargeMobile.copyWith(
                              color: AppColors.blue,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppDimens.xs),
                          Text(
                            'Create your student account to get started.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppDimens.lg),

                          // Error alert container if any error
                          if (auth.errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(AppDimens.sm),
                              decoration: BoxDecoration(
                                color: AppColors.redLight,
                                borderRadius: AppDimens.borderMd,
                                border: Border.all(
                                  color: AppColors.red.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: AppColors.red,
                                    size: 20,
                                  ),
                                  const SizedBox(width: AppDimens.xs),
                                  Expanded(
                                    child: Text(
                                      auth.errorMessage!,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: AppColors.red,
                                    ),
                                    onPressed: auth.clearError,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppDimens.md),
                          ],

                          // Full Name
                          AppTextField(
                            label: 'Full Name',
                            hint: 'Vijay',
                            controller: _nameController,
                            isRequired: true,
                            prefixIcon: Icons.person_outline,
                            validator: (val) =>
                                val == null || val.trim().isEmpty
                                ? 'Please enter your full name'
                                : null,
                          ),
                          const SizedBox(height: AppDimens.md),

                          // Student ID / USN (Optional)
                          AppTextField(
                            label: 'Student ID / USN ',
                            hint: 'e.g. UVCE21CS045',
                            controller: _studentIdController,
                            isRequired: false,
                            prefixIcon: Icons.badge_outlined,
                          ),
                          const SizedBox(height: AppDimens.md),

                          // University Email
                          AppTextField(
                            label: 'University Email',
                            hint: 'student@uvce.edu',
                            controller: _emailController,
                            isRequired: true,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                            validator: (val) =>
                                val == null || !val.contains('@')
                                ? 'Please enter a valid email'
                                : null,
                          ),
                          const SizedBox(height: AppDimens.md),

                          // Phone Number
                          AppTextField(
                            label: 'Phone Number',
                            hint: '+91 98765 43210',
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            prefixIcon: Icons.phone_outlined,
                          ),
                          const SizedBox(height: AppDimens.md),

                          // Branch and Ending Year Row
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: AppDropdown<String>(
                                  label: 'Branch',
                                  hint: 'Select Branch',
                                  value: _selectedBranch,
                                  isRequired: true,
                                  items: _branches
                                      .map(
                                        (b) => DropdownMenuItem(
                                          value: b,
                                          child: Text(
                                            b,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) =>
                                      setState(() => _selectedBranch = val),
                                ),
                              ),
                              const SizedBox(width: AppDimens.sm),
                              Expanded(
                                flex: 2,
                                child: AppDropdown<int>(
                                  label: 'Ending Year',
                                  hint: 'Year',
                                  value: _selectedEndingYear,
                                  isRequired: true,
                                  items: _endingYears
                                      .map(
                                        (y) => DropdownMenuItem(
                                          value: y,
                                          child: Text('$y'),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) =>
                                      setState(() => _selectedEndingYear = val),
                                ),
                              ),
                            ],
                          ),

                          // If "Others" is selected, provide text input to specify custom branch
                          if (_selectedBranch == 'Others') ...[
                            const SizedBox(height: AppDimens.md),
                            AppTextField(
                              label: 'Specify Branch',
                              hint:
                                  'e.g. Bio-Technology, Robotics, Data Science',
                              controller: _otherBranchController,
                              isRequired: true,
                              prefixIcon: Icons.edit_note_outlined,
                              validator: (val) {
                                if (_selectedBranch == 'Others' &&
                                    (val == null || val.trim().isEmpty)) {
                                  return 'Please specify your branch';
                                }
                                return null;
                              },
                            ),
                          ],
                          const SizedBox(height: AppDimens.md),

                          // Password
                          AppTextField(
                            label: 'Password',
                            hint: '••••••••',
                            controller: _passwordController,
                            isPassword: _obscurePassword,
                            isRequired: true,
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.outline,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            validator: (val) => val == null || val.length < 6
                                ? 'Minimum 6 characters required'
                                : null,
                          ),
                          const SizedBox(height: AppDimens.md),

                          // Confirm Password
                          AppTextField(
                            label: 'Confirm Password',
                            hint: '••••••••',
                            controller: _confirmPasswordController,
                            isPassword: _obscureConfirmPassword,
                            isRequired: true,
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.outline,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                            validator: (val) => val == null || val.isEmpty
                                ? 'Please confirm your password'
                                : null,
                          ),
                          const SizedBox(height: AppDimens.lg),

                          // Sign up button
                          PrimaryButton(
                            label: 'Sign Up',
                            onPressed: _handleRegister,
                            isLoading: auth.isLoading,
                            backgroundColor: AppColors.green,
                          ),
                          const SizedBox(height: AppDimens.md),

                          // Already have an account?
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Text(
                                  'Log in',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.blue,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimens.md),

                          // Footer
                          Text(
                            'Powered by GDG UVCE',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.outline,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
