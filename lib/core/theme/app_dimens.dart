import 'package:flutter/material.dart';

/// Spacing, Padding, and Radius constants from Stitch design
class AppDimens {
  AppDimens._();

  // Spacing Units
  static const double unit = 4.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const double marginMobile = 16.0;
  static const double marginDesktop = 48.0;
  static const double gutter = 16.0;

  // Border Radii
  static const double radiusSm = 6.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radius2Xl = 24.0;
  static const double radiusPill = 999.0;

  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderXl = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius border2Xl = BorderRadius.all(Radius.circular(radius2Xl));
  static const BorderRadius borderPill = BorderRadius.all(Radius.circular(radiusPill));

  // Soft shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0D000000), // 5% black
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Color(0x14000000), // 8% black
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> topSheetShadow = [
    BoxShadow(
      color: Color(0x1A000000), // 10% black
      blurRadius: 24,
      offset: Offset(0, -4),
    ),
  ];
}
