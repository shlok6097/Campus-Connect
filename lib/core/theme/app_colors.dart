import 'package:flutter/material.dart';

/// Campus Connect Official Theme Colors
/// Strict 5-color palette: Green, Blue, Red, Orange, White + Clean Neutrals
class AppColors {
  AppColors._();

  // --- Official 5 Core Colors ---
  /// Green: Primary actions, CTA buttons, verified badges, success indicators
  static const Color green = Color(0xFF008744);
  static const Color greenLight = Color(0xFFE6F4EA);
  static const Color greenDark = Color(0xFF006D36);

  /// Blue: Navigation bar, active links, info highlights, header accents
  static const Color blue = Color(0xFF0057E7);
  static const Color blueLight = Color(0xFFE8F0FE);
  static const Color blueDark = Color(0xFF003DA9);
  static const Color blueContainer = Color(0xFF3F51B5);
  static const Color blueOnContainer = Color(0xFFCACFFF);

  /// Red: Delete/Remove actions, errors, cancel, PDF icon indicators
  static const Color red = Color(0xFFD62D20);
  static const Color redLight = Color(0xFFFCE8E6);
  static const Color redContainer = Color(0xFFFFDAD6);
  static const Color redDark = Color(0xFFBA1A1A);

  /// Orange / Yellow: Highlights, points, prizes, rankings, important status badges
  static const Color orange = Color(0xFFFFA700);
  static const Color orangeLight = Color(0xFFFFF3E0);
  static const Color orangeContainer = Color(0xFFFFDCC6);
  static const Color orangeDark = Color(0xFF8F4700);
  static const Color yellow = Color(0xFFFFA700);

  /// White: Backgrounds, card surfaces, form inputs
  static const Color white = Color(0xFFFFFFFF);

  // --- Neutral Surfaces & Borders ---
  static const Color background = Color(0xFFFCF9F8);
  static const Color surface = Color(0xFFFCF9F8);
  static const Color surfaceBright = Color(0xFFFFFFFF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF6F3F2);
  static const Color surfaceContainer = Color(0xFFF0EDED);
  static const Color surfaceContainerHigh = Color(0xFFEAE7E7);
  static const Color surfaceContainerHighest = Color(0xFFE5E2E1);
  static const Color surfaceVariant = Color(0xFFE2E2E2);

  // --- Outlines & Dividers ---
  static const Color outline = Color(0xFF757684);
  static const Color outlineVariant = Color(0xFFC5C5D4);
  static const Color borderSubtle = Color(0xFFE5E7EB);

  // --- Text Colors ---
  static const Color textPrimary = Color(0xFF1C1B1B);
  static const Color textSecondary = Color(0xFF5C5F60);
  static const Color textMuted = Color(0xFF757684);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  // --- Gradients ---
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0xCC000000),
    ],
  );

  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF008744),
      Color(0xFF00A854),
    ],
  );

  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0057E7),
      Color(0xFF24389C),
    ],
  );
}
