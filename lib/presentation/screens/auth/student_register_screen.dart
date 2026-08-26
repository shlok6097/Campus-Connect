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

  String? _selectedBranch;
  int? _selectedSemester;
  bool _isLoading = false;

  final List<String> _branches = [
    'Computer Science & Engineering',
    'Information Science & Engineering',
    'Electronics & Communication',
    'Electrical & Electronics',
    'Mechanical Engineering',
    'Civil Engineering',
  ];

  final List<int> _semesters = [1, 2, 3, 4, 5, 6, 7, 8];

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBranch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your branch')),
      );
      return;
    }
    if (_selectedSemester == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your semester')),
      );
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      AuthController.instance.registerStudent(
        name: _nameController.text,
        studentId: _studentIdController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        branch: _selectedBranch!,
        semester: _selectedSemester!,
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const StudentShellScreen()),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                    const SizedBox(height: AppDimens.xl),

                    // Full Name
                    AppTextField(
                      label: 'Full Name',
                      hint: 'John Doe',
                      controller: _nameController,
                      isRequired: true,
                      prefixIcon: Icons.person_outline,
                      validator: (val) => val == null || val.isEmpty ? 'Please enter your full name' : null,
                    ),
                    const SizedBox(height: AppDimens.md),

                    // Student ID / USN
                    AppTextField(
                      label: 'Student ID / USN',
                      hint: 'UVCE21CS045',
                      controller: _studentIdController,
                      isRequired: true,
                      prefixIcon: Icons.badge_outlined,
                      validator: (val) => val == null || val.isEmpty ? 'Please enter your Student ID or USN' : null,
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
                      validator: (val) => val == null || !val.contains('@') ? 'Please enter a valid email' : null,
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

                    // Branch and Semester Row
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: AppDropdown<String>(
                            label: 'Branch',
                            hint: 'Select Branch',
                            value: _selectedBranch,
                            isRequired: true,
                            items: _branches.map((b) => DropdownMenuItem(value: b, child: Text(b, overflow: TextOverflow.ellipsis))).toList(),
                            onChanged: (val) => setState(() => _selectedBranch = val),
                          ),
                        ),
                        const SizedBox(width: AppDimens.sm),
                        Expanded(
                          flex: 2,
                          child: AppDropdown<int>(
                            label: 'Semester',
                            hint: 'Sem',
                            value: _selectedSemester,
                            isRequired: true,
                            items: _semesters.map((s) => DropdownMenuItem(value: s, child: Text('Sem $s'))).toList(),
                            onChanged: (val) => setState(() => _selectedSemester = val),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.md),

                    // Password
                    AppTextField(
                      label: 'Password',
                      hint: '••••••••',
                      controller: _passwordController,
                      isPassword: true,
                      isRequired: true,
                      prefixIcon: Icons.lock_outline,
                      validator: (val) => val == null || val.length < 6 ? 'Minimum 6 characters' : null,
                    ),
                    const SizedBox(height: AppDimens.md),

                    // Confirm Password
                    AppTextField(
                      label: 'Confirm Password',
                      hint: '••••••••',
                      controller: _confirmPasswordController,
                      isPassword: true,
                      isRequired: true,
                      prefixIcon: Icons.lock_outline,
                      validator: (val) => val == null || val.isEmpty ? 'Please confirm your password' : null,
                    ),
                    const SizedBox(height: AppDimens.xl),

                    // Sign up button
                    PrimaryButton(
                      label: 'Sign Up',
                      onPressed: _handleRegister,
                      isLoading: _isLoading,
                      backgroundColor: AppColors.green,
                    ),
                    const SizedBox(height: AppDimens.md),

                    // Already have an account?
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
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
                    const SizedBox(height: AppDimens.lg),

                    // Footer
                    Text(
                      'Powered by GDG UVCE',
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.outline),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
