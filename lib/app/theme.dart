import 'package:flutter/material.dart';

import '../core/constants/app_fonts.dart';
import '../core/constants/app_sizes.dart';
import 'app_colors.dart';

/// Builds the day and night [ThemeData] from the design tokens.
class AppTheme {
  /// Theme used when the phone is in light mode.
  static ThemeData day() {
    return _build(AppColors.day, Brightness.light);
  }

  /// Theme used when the phone is in dark mode (bedtime palette).
  static ThemeData night() {
    return _build(AppColors.night, Brightness.dark);
  }

  static ThemeData _build(AppColors colors, Brightness brightness) {
    // ── Colour scheme ──
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      onPrimary: brightness == Brightness.light
          ? Colors.white
          : AppColors.day.ink,
      secondary: colors.sunshine,
      onSecondary: AppColors.day.ink,
      error: colors.coralSoft,
      onError: AppColors.day.ink,
      surface: colors.surface,
      onSurface: colors.ink,
    );

    // ── Text styles ──
    final textTheme = TextTheme(
      displaySmall: TextStyle(
        fontFamily: AppFonts.fredoka,
        fontWeight: FontWeight.w700,
        fontSize: 36,
        color: colors.ink,
      ),
      headlineSmall: TextStyle(
        fontFamily: AppFonts.fredoka,
        fontWeight: FontWeight.w700,
        fontSize: 24,
        color: colors.ink,
      ),
      titleMedium: TextStyle(
        fontFamily: AppFonts.fredoka,
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: colors.ink,
      ),
      bodyLarge: TextStyle(
        fontFamily: AppFonts.nunito,
        fontSize: 16,
        color: colors.ink,
      ),
      bodyMedium: TextStyle(
        fontFamily: AppFonts.nunito,
        fontSize: 14,
        color: colors.inkMuted,
      ),
      labelLarge: TextStyle(
        fontFamily: AppFonts.nunito,
        fontWeight: FontWeight.w700,
        fontSize: 16,
        color: colors.ink,
      ),
    );

    // ── Buttons ──
    final filledButtonTheme = FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(AppSizes.readerTouchTarget),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
        ),
        textStyle: const TextStyle(
          fontFamily: AppFonts.nunito,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );

    // ── Text fields ──
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colors.border),
    );
    final inputTheme = InputDecorationTheme(
      filled: true,
      fillColor: colors.surface,
      border: fieldBorder,
      enabledBorder: fieldBorder,
      focusedBorder: fieldBorder.copyWith(
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      fontFamily: AppFonts.nunito,
      textTheme: textTheme,
      filledButtonTheme: filledButtonTheme,
      inputDecorationTheme: inputTheme,
    );
  }
}
