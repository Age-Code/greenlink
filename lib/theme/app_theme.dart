import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFFF8F5EC); // or FAF7EF
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color primaryGreen = Color(0xFF9FD978);
  static const Color softGreen = Color(0xFFDDF2C6);
  static const Color deepGreen = Color(0xFF5E8F46);
  static const Color softYellow = Color(0xFFF3E46B);
  static const Color warmBrown = Color(0xFF9A7868);
  static const Color textPrimary = Color(0xFF3D3A34);
  static const Color textSecondary = Color(0xFF8B877D);
  static const Color borderSoft = Color(0xFFEEE8DA);

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: background,
      primaryColor: primaryGreen,
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        secondary: softYellow,
        background: background,
        surface: cardBackground,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: textPrimary, fontSize: 14),
        bodySmall: TextStyle(color: textSecondary, fontSize: 12),
        titleLarge: TextStyle(
            color: textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(
            color: textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        titleSmall: TextStyle(
            color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 0.5,
        shadowColor: borderSoft.withOpacity(0.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: deepGreen,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardBackground,
        selectedColor: softGreen,
        labelStyle: const TextStyle(color: textPrimary),
        secondaryLabelStyle: const TextStyle(color: deepGreen),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderSoft),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardBackground,
        selectedItemColor: primaryGreen,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
