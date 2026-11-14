import 'package:flutter/material.dart';

abstract final class AppColors {
  static const green = Color(0xFF00A859);
  static const darkGreen = Color(0xFF007A42);
  static const orange = Color(0xFFB85C00);
  static const gold = Color(0xFFFFC800);
  static const darkGold = Color(0xFF8A6500);
  static const error = Color(0xFFE53935);
}

abstract final class AppTheme {
  static final light = ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.darkGreen,
      onPrimary: Colors.white,
      secondary: AppColors.darkGold,
      onSecondary: Colors.white,
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF17231D),
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: const Color(0xFFE8EDEA),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFFFFFF),
      foregroundColor: Color(0xFF17231D),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFFFFFFFF),
      selectedItemColor: AppColors.orange,
      unselectedItemColor: Color(0xFF66756D),
      type: BottomNavigationBarType.fixed,
    ),
    dividerColor: Color(0xFFE0E7E2),
    inputDecorationTheme: const InputDecorationTheme(
      fillColor: Color(0xFFFFFFFF),
    ),
  );

  static final dark = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: const Color(0xFF12161A),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.green,
      onPrimary: Colors.white,
      secondary: AppColors.gold,
      onSecondary: Color(0xFF12161A),
      surface: Color(0xFF1E232A),
      onSurface: Colors.white,
      error: AppColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E232A),
      foregroundColor: Colors.white,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E232A),
      selectedItemColor: AppColors.gold,
      unselectedItemColor: Color(0xFF6C7A89),
      type: BottomNavigationBarType.fixed,
    ),
    dividerColor: const Color(0xFF2A323D),
    inputDecorationTheme: const InputDecorationTheme(
      fillColor: Color(0xFF1E232A),
    ),
  );
}

abstract final class AppTextStyles {
  static const pageTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  static const sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
  static const body = TextStyle(fontSize: 16);
  static const muted = TextStyle();
  static const subtle = TextStyle();
}
