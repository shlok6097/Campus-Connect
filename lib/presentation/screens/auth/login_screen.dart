import 'package:flutter/material.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../shared/buttons/primary_button.dart';
import '../../shared/inputs/app_text_field.dart';
import '../../state/auth_controller.dart';
import 'student_register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final auth = AuthController.instance;
    final success = await auth.login(
      identifier: _identifierController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      final user = auth.currentUser;
      final targetRoute = AppRoutes.getDashboardRoute(user);

      Navigator.of(context).pushReplacementNamed(targetRoute);
    }
  }

  void _showForgotPasswordModal() {
    final resetController = TextEditingController(text: _identifierController.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: AppDimens.borderLg),
        title: Text(
          'Reset Password',
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.blue),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter your registered email address or student ID. We will send you instructions to reset your password.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimens.md),
            AppTextField(
              label: 'Email or Student ID',
              hint: 'e.g. rahul.kumar@uvce.edu',
              controller: resetController,
              prefixIcon: Icons.email_outlined,
              isRequired: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final id = resetController.text.trim();
              if (id.isEmpty) return;
              Navigator.of(ctx).pop();
              await AuthController.instance.requestPasswordReset(id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AuthController.instance.successMessage ??
                          'Password reset instructions sent to your email.',
                    ),
                    backgroundColor: AppColors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.marginMobile,
              vertical: AppDimens.lg,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: AnimatedBuilder(
                animation: AuthController.instance,
                builder: (context, _) {
                  final auth = AuthController.instance;

                  return Container(
                    padding: const EdgeInsets.all(AppDimens.xl),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: AppDimens.borderXl,
                      border: Border.all(color: AppColors.outlineVariant),
                      boxShadow: AppDimens.cardShadow,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header / Branding
                          Center(
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.blueLight,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.outlineVariant),
                              ),
                              child: const Icon(
                                Icons.hub_outlined,
                                size: 32,
                                color: AppColors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDimens.md),
                          Text(
                            'Campus Connect',
                            style: AppTextStyles.displayLargeMobile.copyWith(
                              color: AppColors.blue,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppDimens.xs),
                          Text(
                            'Sign in to continue',
                            style: AppTextStyles.bodySmall.copyWith(
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

                          // Email / Student ID / Username Input
                          AppTextField(
                            label: 'Email or Student ID',
                            hint: 'Enter your email or ID',
                            controller: _identifierController,
                            isRequired: true,
                            prefixIcon: Icons.person_outline,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your email, student ID, or username';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppDimens.md),

                          // Password Input
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
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppDimens.xs),

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _showForgotPasswordModal,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Forgot Password?',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.blue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDimens.lg),

                          // Primary Action: Login
                          PrimaryButton(
                            label: 'Login',
                            icon: Icons.arrow_forward,
                            onPressed: _handleLogin,
                            isLoading: auth.isLoading,
                            backgroundColor: AppColors.blue,
                          ),
                          const SizedBox(height: AppDimens.lg),

                          // Divider "or"
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(
                                  color: AppColors.outlineVariant,
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
                                child: Text(
                                  'or',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.outline,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(
                                  color: AppColors.outlineVariant,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimens.lg),

                          // Secondary Action: Create Student Account
                          OutlinedButton.icon(
                            onPressed: () {
                              auth.clearError();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const StudentRegisterScreen(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.school_outlined,
                              color: AppColors.blue,
                              size: 20,
                            ),
                            label: Text(
                              'Create Student Account',
                              style: AppTextStyles.titleLarge.copyWith(
                                color: AppColors.blue,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.outlineVariant),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppDimens.borderMd,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDimens.xl),

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
