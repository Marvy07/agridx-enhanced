import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary brand
  static const Color primary = Color(0xFF0A3D1F);
  static const Color primaryLight = Color(0xFF1A5C30);
  static const Color primaryDark = Color(0xFF062614);
  static const Color primarySurface = Color(0xFFE8F5EC);

  // Accent
  static const Color accent = Color(0xFF4CAF50);
  static const Color accentLight = Color(0xFF81C784);

  // Background
  static const Color background = Color(0xFFF5F0E8);
  static const Color backgroundAlt = Color(0xFFEDE8DF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFAF8F4);

  // Text
  static const Color textPrimary = Color(0xFF0A1F0F);
  static const Color textSecondary = Color(0xFF4A5C4F);
  static const Color textHint = Color(0xFF8FA896);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSurface = Color(0xFF0A1F0F);

  // Semantic
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57F17);
  static const Color error = Color(0xFFC62828);
  static const Color info = Color(0xFF1565C0);

  // Severity
  static const Color severityLow = Color(0xFF43A047);
  static const Color severityMedium = Color(0xFFFB8C00);
  static const Color severityHigh = Color(0xFFE53935);
  static const Color severityCritical = Color(0xFF880E4F);

  // Border / divider
  static const Color border = Color(0xFFD6CFC4);
  static const Color divider = Color(0xFFE8E2D8);

  // Card overlay gradient
  static const LinearGradient cardOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xCC0A3D1F)],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A3D1F), Color(0xFF1A5C30)],
  );
}
