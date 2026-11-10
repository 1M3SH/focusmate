import 'package:flutter/material.dart';

/// Colour palette for FocusMate.
/// Designed for accessibility with sufficient contrast ratios (WCAG AA).
class AppColors {
  AppColors._();

  // Brand colours
  static const Color primary = Color(0xFF5B6EF5);
  static const Color primaryLight = Color(0xFF8A9BFF);
  static const Color primaryDark = Color(0xFF3A4FD4);
  static const Color secondary = Color(0xFF00C9A7);
  static const Color secondaryLight = Color(0xFF5DFCD8);
  static const Color secondaryDark = Color(0xFF009978);

  // Accent / semantic colours
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // Priority colours
  static const Color priorityLow = Color(0xFF4CAF50);
  static const Color priorityMedium = Color(0xFFFFC107);
  static const Color priorityHigh = Color(0xFFE53935);

  // Light theme surfaces
  static const Color backgroundLight = Color(0xFFF8F9FF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color dividerLight = Color(0xFFE5E7EB);

  // Dark theme surfaces
  static const Color backgroundDark = Color(0xFF0F0F1A);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color cardDark = Color(0xFF252540);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color dividerDark = Color(0xFF334155);

  // Gradient presets
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient focusGradient = LinearGradient(
    colors: [Color(0xFF5B6EF5), Color(0xFF00C9A7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Category chip colours
  static const List<Color> categoryColors = [
    Color(0xFF5B6EF5),
    Color(0xFF00C9A7),
    Color(0xFFFF6B6B),
    Color(0xFFFFD93D),
    Color(0xFF6BCB77),
    Color(0xFF4D96FF),
    Color(0xFFFF6FC8),
    Color(0xFFBF9B30),
  ];
}
