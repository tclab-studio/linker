import 'package:flutter/material.dart';

class AppTheme {
  static const _seedColor = Color(0xFF6C63FF);
  static const bgDark = Color(0xFF0D0D14);
  static const surface = Color(0xFF16161F);
  static const cardColor = Color(0xFF1E1E2C);
  static const accent = Color(0xFF6C63FF);
  static const accentGlow = Color(0x336C63FF);
  static const success = Color(0xFF4ADE80);
  static const errorColor = Color(0xFFFF6B6B);
  static const textPrimary = Color(0xFFF0F0F8);
  static const textMuted = Color(0xFF8888AA);

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
      surface: bgDark,
    ),
    scaffoldBackgroundColor: bgDark,
    cardColor: cardColor,
    fontFamily: 'SF Pro Display',
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: textPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        color: textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
      bodyMedium: TextStyle(color: textMuted, fontSize: 14),
      labelSmall: TextStyle(
        color: textMuted,
        fontSize: 11,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}
