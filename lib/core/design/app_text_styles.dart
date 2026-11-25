import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Display — Outfit, used for hero titles
  static TextStyle display1 = GoogleFonts.outfit(
    fontSize: 40, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, height: 1.1, letterSpacing: -0.5,
  );
  static TextStyle display2 = GoogleFonts.outfit(
    fontSize: 32, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, height: 1.15, letterSpacing: -0.3,
  );

  // Headings — Outfit
  static TextStyle h1 = GoogleFonts.outfit(
    fontSize: 26, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, height: 1.2,
  );
  static TextStyle h2 = GoogleFonts.outfit(
    fontSize: 22, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, height: 1.25,
  );
  static TextStyle h3 = GoogleFonts.outfit(
    fontSize: 18, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, height: 1.3,
  );
  static TextStyle h4 = GoogleFonts.outfit(
    fontSize: 16, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, height: 1.35,
  );

  // Body — Inter
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16, fontWeight: FontWeight.w400,
    color: AppColors.textPrimary, height: 1.6,
  );
  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w400,
    color: AppColors.textPrimary, height: 1.6,
  );
  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary, height: 1.5,
  );

  // Labels & captions
  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w500,
    color: AppColors.textPrimary, height: 1.4, letterSpacing: 0.1,
  );
  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w500,
    color: AppColors.textSecondary, height: 1.4, letterSpacing: 0.3,
  );
  static TextStyle caption = GoogleFonts.inter(
    fontSize: 11, fontWeight: FontWeight.w400,
    color: AppColors.textHint, height: 1.4, letterSpacing: 0.2,
  );

  // Button text
  static TextStyle buttonLarge = GoogleFonts.outfit(
    fontSize: 16, fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary, height: 1.2, letterSpacing: 0.2,
  );
  static TextStyle buttonMedium = GoogleFonts.outfit(
    fontSize: 14, fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary, height: 1.2, letterSpacing: 0.2,
  );
}
