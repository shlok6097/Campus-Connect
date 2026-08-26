import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../shared/buttons/primary_button.dart';
import '../../shared/inputs/app_text_field.dart';
import '../../state/auth_controller.dart';
import '../student/student_shell_screen.dart';
import '../organizer/organizer_shell_screen.dart';
import 'student_register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'rahul.kumar@uvce.edu');
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscurePassword = true;
  bool _isOrganizerMode = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (_isOrganizerMode) {
        AuthController.instance.loginOrganizer(
          clubOrRole: 'Coding Club Manager',
          password: _passwordController.text,
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OrganizerShellScreen()),
        );
      } else {
        AuthController.instance.loginStudent(
          email: _emailController.text,
          password: _passwordController.text,
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const StudentShellScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.marginMobile,
              vertical: AppDimens.lg,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Icon
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.blueLight,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.outlineVariant),
                        ),
                        child: const Icon(Icons.hub, size: 36, color: AppColors.blue),
                      ),
                    ),
                    const SizedBox(height: AppDimens.md),
                    // Title & Subtitle
                    Text(
                      'Welcome to Campus Connect',
                      style: AppTextStyles.displayLargeMobile.copyWith(
                        color: AppColors.blue,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimens.xs),
                    Text(
                      _isOrganizerMode
                          ? 'Sign in to manage club events and responses'
                          : 'Sign in to access events, clubs, teams & notes',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimens.xl),

                    // Role Switcher Tab
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: AppDimens.borderLg,
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isOrganizerMode = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: !_isOrganizerMode ? AppColors.white : Colors.transparent,
                                  borderRadius: AppDimens.borderMd,
                                  boxShadow: !_isOrganizerMode ? AppDimens.cardShadow : null,
                                ),
                                child: Text(
                                  'Student Portal',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: !_isOrganizerMode ? AppColors.blue : AppColors.textSecondary,
                                    fontWeight: !_isOrganizerMode ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isOrganizerMode = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _isOrganizerMode ? AppColors.white : Colors.transparent,
                                  borderRadius: AppDimens.borderMd,
                                  boxShadow: _isOrganizerMode ? AppDimens.cardShadow : null,
                                ),
                                child: Text(
                                  'Club Organizer',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: _isOrganizerMode ? AppColors.blue : AppColors.textSecondary,
                                    fontWeight: _isOrganizerMode ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimens.lg),

                    // Email / USN Field
                    AppTextField(
                      label: _isOrganizerMode ? 'Club Email / Admin ID' : 'University Email or USN',
                      hint: _isOrganizerMode ? 'codingclub@uvce.edu' : 'student@uvce.edu or UVCE21CS045',
                      controller: _emailController,
                      prefixIcon: Icons.email_outlined,
                      isRequired: true,
                      validator: (val) => val == null || val.isEmpty ? 'Please enter your email or USN' : null,
                    ),
                    const SizedBox(height: AppDimens.md),

                    // Password Field
                    AppTextField(
                      label: 'Password',
                      hint: '••••••••',
                      controller: _passwordController,
                      isPassword: _obscurePassword,
                      isRequired: true,
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: AppColors.outline,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (val) => val == null || val.length < 6 ? 'Password must be at least 6 characters' : null,
                    ),
                    const SizedBox(height: AppDimens.xs),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password reset link sent to your email.')),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimens.md),

                    // Login Action Button
                    PrimaryButton(
                      label: _isOrganizerMode ? 'Continue as Organizer' : 'Continue as Student',
                      onPressed: _handleLogin,
                      isLoading: _isLoading,
                      backgroundColor: _isOrganizerMode ? AppColors.blue : AppColors.green,
                    ),
                    const SizedBox(height: AppDimens.md),

                    // Sign up prompt
                    if (!_isOrganizerMode) ...[
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const StudentRegisterScreen()),
                              );
                            },
                            child: Text(
                              'Sign Up',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.blue,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimens.lg),
                    ],

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
