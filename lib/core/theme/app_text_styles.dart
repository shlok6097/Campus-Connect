import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Inter Typography Scale matching Stitch Design System
class AppTextStyles {
  AppTextStyles._();

  /// Display Large (32px, 40px line-height, bold, letter-spacing -0.02em)
  static TextStyle displayLarge = GoogleFonts.inter(
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.64,
    color: AppColors.textPrimary,
  );

  /// Display Large Mobile (28px, 34px line-height, bold)
  static TextStyle displayLargeMobile = GoogleFonts.inter(
    fontSize: 28,
    height: 34 / 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.56,
    color: AppColors.textPrimary,
  );

  /// Headline Medium (24px, 32px line-height, semi-bold, letter-spacing -0.01em)
  static TextStyle headlineMedium = GoogleFonts.inter(
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.24,
    color: AppColors.textPrimary,
  );

  /// Display Small / Headline Medium (24px, 32px line-height, semi-bold)
  static TextStyle displaySmall = headlineMedium;

  /// Headline Small (20px, 28px line-height, semi-bold)
  static TextStyle headlineSmall = GoogleFonts.inter(
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Title Large (18px, 24px line-height, semi-bold)
  static TextStyle titleLarge = GoogleFonts.inter(
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Title Medium (16px, 22px line-height, semi-bold)
  static TextStyle titleMedium = GoogleFonts.inter(
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Body Large (16px, 24px line-height, semi-bold)
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Body Medium (16px, 24px line-height, regular)
  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// Body Small (14px, 20px line-height, regular)
  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Label Large (14px, 20px line-height, semi-bold)
  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Label Medium (12px, 16px line-height, semi-bold, letter-spacing 0.05em)
  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6,
    color: AppColors.textSecondary,
  );

  /// Monospace / Code Style for Technical Games
  static TextStyle code = GoogleFonts.jetBrainsMono(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
}
