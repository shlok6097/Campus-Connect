import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.green,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.green,
        onPrimary: AppColors.white,
        primaryContainer: AppColors.greenLight,
        onPrimaryContainer: AppColors.greenDark,
        secondary: AppColors.blue,
        onSecondary: AppColors.white,
        secondaryContainer: AppColors.blueLight,
        onSecondaryContainer: AppColors.blueDark,
        error: AppColors.red,
        onError: AppColors.white,
        errorContainer: AppColors.redContainer,
        onErrorContainer: AppColors.redDark,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayLargeMobile,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        bodyLarge: AppTextStyles.bodyMedium,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelMedium: AppTextStyles.labelMedium,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.blue),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimens.borderXl,
          side: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.lg, vertical: AppDimens.md),
          shape: RoundedRectangleBorder(borderRadius: AppDimens.borderMd),
          textStyle: AppTextStyles.titleLarge.copyWith(color: AppColors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.blue,
          side: const BorderSide(color: AppColors.outlineVariant),
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.lg, vertical: AppDimens.md),
          shape: RoundedRectangleBorder(borderRadius: AppDimens.borderMd),
          textStyle: AppTextStyles.titleLarge.copyWith(color: AppColors.blue),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: AppDimens.md),
        border: OutlineInputBorder(
          borderRadius: AppDimens.borderMd,
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDimens.borderMd,
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDimens.borderMd,
          borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppDimens.borderMd,
          borderSide: const BorderSide(color: AppColors.red),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.outline),
        labelStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
