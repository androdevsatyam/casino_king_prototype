import 'package:flutter/material.dart';
import 'casino_colors.dart';

class CasinoTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: CasinoColors.bgPrimary,
      primaryColor: CasinoColors.gold,
      colorScheme: const ColorScheme.dark(
        primary: CasinoColors.gold,
        onPrimary: Colors.black,
        secondary: CasinoColors.goldAccent,
        onSecondary: Colors.black,
        surface: CasinoColors.bgSecondary,
        onSurface: CasinoColors.textPrimary,
        error: CasinoColors.hotRed,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: CasinoColors.bgDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: CasinoColors.gold),
        titleTextStyle: TextStyle(
          color: CasinoColors.gold,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: CasinoColors.bgCard,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: CasinoColors.borderGoldSubtle, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: CasinoColors.bgCardElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: CasinoColors.gold, width: 1.5),
        ),
        titleTextStyle: const TextStyle(
          color: CasinoColors.goldBright,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CasinoColors.gold,
          foregroundColor: Colors.black,
          elevation: 6,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CasinoColors.bgDark.withValues(alpha: 0.6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CasinoColors.borderMuted),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CasinoColors.borderGoldSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CasinoColors.gold, width: 1.5),
        ),
        labelStyle: const TextStyle(color: CasinoColors.textSecondary),
        hintStyle: const TextStyle(color: CasinoColors.textMuted),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: CasinoColors.bgBottomNav,
        selectedItemColor: CasinoColors.gold,
        unselectedItemColor: CasinoColors.textMuted,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),
    );
  }
}
