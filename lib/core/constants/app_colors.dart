import 'package:flutter/material.dart';

class AppColors {
  // Background Base
  static const Color obsidianBase = Color(0xFF0B0F17);
  static const Color midnightSand = Color(0xFF0E1420);
  static const Color darkCanvas = Color(0xFF090D14);

  // Surface & Cards
  static const Color slateCard = Color(0xFF161F2E);
  static const Color slateCardElevated = Color(0xFF1E293B);
  static const Color slateBorder = Color(0xFF243247);
  static const Color slateDivider = Color(0xFF1F2B3E);

  // Emerald Oasis Glow (Primary)
  static const Color emeraldPrimary = Color(0xFF10B981);
  static const Color emeraldLight = Color(0xFF34D399);
  static const Color emeraldDark = Color(0xFF065F46);
  static const Color emeraldGlow = Color(0x3310B981);

  // Warm Desert Amber (Secondary & Highlights)
  static const Color amberWarm = Color(0xFFF59E0B);
  static const Color amberLight = Color(0xFFFBBF24);
  static const Color amberGlow = Color(0x33F59E0B);

  // Crimson & Hearts
  static const Color crimsonHeart = Color(0xFFEF4444);
  static const Color crimsonGlow = Color(0x33EF4444);

  // Text & Foregrounds
  static const Color textHighContrast = Color(0xFFF8FAFC);
  static const Color textMediumContrast = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textWhite = Colors.white;

  // Accents & Gradients
  static const LinearGradient heroStageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x3310B981),
      Color(0x000B0F17),
      Color(0xEE0B0F17),
    ],
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A2638),
      Color(0xFF141D2B),
    ],
  );

  static const LinearGradient emeraldButtonGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );

  static const LinearGradient amberGoldGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
  );
}
