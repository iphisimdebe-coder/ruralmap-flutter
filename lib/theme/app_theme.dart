import 'package:flutter/material.dart';

/// Central place for colors, text styles and spacing so every
/// reusable widget looks consistent across the app.
class AppColors {
  AppColors._();

  static const primary = Color(0xFF1B4332); // deep forest green
  static const primaryDark = Color(0xFF12332A);
  static const primaryLight = Color(0xFF2D6A4F);

  static const background = Color(0xFFF7F7F5);
  static const surface = Colors.white;

  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6B7280);
  static const divider = Color(0xFFE5E7EB);

  static const houseBg = Color(0xFFE3F2E8);
  static const houseFg = Color(0xFF2D6A4F);

  static const businessBg = Color(0xFFFDECD8);
  static const businessFg = Color(0xFFC2732C);

  static const churchBg = Color(0xFFEDE5F9);
  static const churchFg = Color(0xFF7C4DBE);

  static const schoolBg = Color(0xFFDDEBFA);
  static const schoolFg = Color(0xFF2B6CB0);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1),
    );
  }
}
