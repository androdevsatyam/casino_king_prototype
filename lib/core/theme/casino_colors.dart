import 'package:flutter/material.dart';

/// Royal Gold & Treasure Casino Color Palette
class CasinoColors {
  // Royal Gold Palette
  static const Color gold = Color(0xFFFFD700);
  static const Color goldLight = Color(0xFFFFF3B0);
  static const Color goldBright = Color(0xFFFFE082);
  static const Color goldAccent = Color(0xFFF5B014);
  static const Color goldDark = Color(0xFFB87B00);
  static const Color goldBronze = Color(0xFF8B5E00);
  static const Color goldMetallic = Color(0xFFD4AF37);

  // Casino Midnight / Royal Navy Backgrounds
  static const Color bgDark = Color(0xFF070B16);
  static const Color bgPrimary = Color(0xFF0A0F1D);
  static const Color bgSecondary = Color(0xFF0F172A);
  static const Color bgCard = Color(0xFF141E34);
  static const Color bgCardElevated = Color(0xFF1C2744);
  static const Color bgSidebar = Color(0xFF0B1120);
  static const Color bgBottomNav = Color(0xFF080D1A);
  static const Color surfaceOverlay = Color(0x331E293B);

  // Border & Dividers
  static const Color borderGold = Color(0x66FFD700);
  static const Color borderGoldSubtle = Color(0x2ECCA73B);
  static const Color borderMuted = Color(0x264B5563);

  // Vibrant Casino Action Accents
  static const Color winGreen = Color(0xFF00E676);
  static const Color winGreenGlow = Color(0x4D00E676);
  static const Color hotRed = Color(0xFFFF3366);
  static const Color crashRed = Color(0xFFFF2A42);
  static const Color neonOrange = Color(0xFFFF6D00);
  static const Color flameOrange = Color(0xFFFF9100);
  static const Color royalPurple = Color(0xFF9C27B0);
  static const Color sapphireBlue = Color(0xFF2979FF);
  static const Color electricCyan = Color(0xFF00E5FF);

  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textGold = Color(0xFFFFD700);
  static const Color textGoldBright = Color(0xFFFFF1A8);

  // Gradients
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFF3A1), Color(0xFFFFD700), Color(0xFFD49B28)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldMetallicGradient = LinearGradient(
    colors: [
      Color(0xFFF5D77F),
      Color(0xFFFFC000),
      Color(0xFFB87B00),
      Color(0xFFFFDF73),
    ],
    stops: [0.0, 0.45, 0.75, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldButtonGradient = LinearGradient(
    colors: [Color(0xFFFFE066), Color(0xFFFF9E00)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient goldBorderGradient = LinearGradient(
    colors: [
      Color(0xFFFFE57F),
      Color(0xFFFFC107),
      Color(0x22FFC107),
      Color(0xFFFFD54F),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardBgGradient = LinearGradient(
    colors: [Color(0xFF1B253F), Color(0xFF101728)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient activeTabGradient = LinearGradient(
    colors: [Color(0xFF2E3D66), Color(0xFF1A2238)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bannerJackpotGradient = LinearGradient(
    colors: [Color(0xFF0B2149), Color(0xFF1E3A8A), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient aviatorGradient = LinearGradient(
    colors: [Color(0xFF2A0813), Color(0xFF160309)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Shadows & Glows
  static List<BoxShadow> get goldGlow => [
    BoxShadow(
      color: const Color(0xFFFFD700).withValues(alpha: 0.4),
      blurRadius: 12,
      spreadRadius: 1,
    ),
  ];

  static List<BoxShadow> get goldGlowIntense => [
    BoxShadow(
      color: const Color(0xFFFFD700).withValues(alpha: 0.6),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];

  static List<BoxShadow> get redNeonGlow => [
    BoxShadow(
      color: const Color(0xFFFF2A42).withValues(alpha: 0.5),
      blurRadius: 14,
      spreadRadius: 1,
    ),
  ];

  static List<BoxShadow> get cardElevation => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.45),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
}
