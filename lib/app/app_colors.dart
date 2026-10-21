import 'package:flutter/material.dart';

/// Centralized color palette for Life Reset.
/// Strict adherence to the approved visual identity:
/// Forest Green (#173C32), Light Green Accent (#B7F7C5), Soft Off-White (#F7F7F2).
abstract final class AppColors {
  // Brand Colors
  static const Color primaryForestGreen = Color(0xFF173C32);
  static const Color lightGreenAccent = Color(0xFFB7F7C5);
  static const Color darkForestHover = Color(0xFF112D26);

  // Backgrounds & Surfaces
  static const Color appBackground = Color(0xFFF7F7F2);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color accentSurface = Color(0xFFE9F9EE);
  static const Color darkCardBackground = Color(0xFF1E463B);

  // Typography
  static const Color primaryText = Color(0xFF18221E);
  static const Color secondaryText = Color(0xFF68736D);
  static const Color lightText = Color(0xFFF7F7F2);
  static const Color mutedText = Color(0xFF9AA39E);

  // Borders & Dividers
  static const Color subtleBorder = Color(0xFFE6E8E2);
  static const Color subtleDivider = Color(0xFFEBECE7);

  // Functional Status
  static const Color badgeBackground = Color(0xFFE3F3EA);
  static const Color badgeText = Color(0xFF1B5E43);
  static const Color disabledBackground = Color(0xFFE2E4DE);
  static const Color disabledText = Color(0xFF909692);
}
