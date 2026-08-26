import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _timer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, _, _) => const LoginScreen(),
            transitionsBuilder: (_, a, _, c) => FadeTransition(opacity: a, child: c),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Centered Logo & Branding
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.outlineVariant, width: 1.5),
                  boxShadow: AppDimens.elevatedShadow,
                ),
                child: Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: AppColors.blueLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.hub,
                      size: 42,
                      color: AppColors.blue,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimens.lg),
            Text(
              'Campus Connect',
              style: AppTextStyles.displayLarge.copyWith(
                color: AppColors.blue,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppDimens.xs),
            Text(
              'Your All-in-One Campus Experience',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimens.xl),
            // Multi-color bouncing dots (Stitch loader)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(AppColors.blue, 0),
                const SizedBox(width: AppDimens.sm),
                _buildDot(AppColors.red, 200),
                const SizedBox(width: AppDimens.sm),
                _buildDot(AppColors.orange, 400),
                const SizedBox(width: AppDimens.sm),
                _buildDot(AppColors.green, 600),
              ],
            ),
            const Spacer(),
            // Powered by GDG UVCE footer
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.lg),
              child: Text(
                'Powered by GDG UVCE',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.outline,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(Color color, int delayMs) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
