import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.obsidianBase,
      primaryColor: AppColors.emeraldPrimary,
      canvasColor: AppColors.obsidianBase,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.emeraldPrimary,
        secondary: AppColors.amberWarm,
        surface: AppColors.slateCard,
        error: AppColors.crimsonHeart,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: AppColors.textHighContrast,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.obsidianBase.withValues(alpha: 0.95),
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: AppColors.textHighContrast,
          letterSpacing: 0.3,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textHighContrast,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.slateCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.slateBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.emeraldPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.emeraldLight,
          side: const BorderSide(color: AppColors.emeraldPrimary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.midnightSand,
        selectedItemColor: AppColors.emeraldPrimary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  /// Font styling helper for Arabic dialect text (Rule 6: readexPro)
  static TextStyle arabic({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w600,
    Color color = AppColors.textHighContrast,
    double height = 1.45,
  }) {
    return GoogleFonts.readexPro(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  /// Font styling helper for English UI & numbers (outfit)
  static TextStyle latin({
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.w500,
    Color color = AppColors.textHighContrast,
    double? letterSpacing,
  }) {
    return GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  /// Font styling helper for Phonetics, Arabizi & IPA symbols (Rule 6: notoSans)
  static TextStyle phonetic({
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.amberLight,
    double? letterSpacing,
  }) {
    return GoogleFonts.notoSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing ?? 0.2,
    );
  }
}
