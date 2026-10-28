import 'package:flutter/material.dart';

/// Design tokens from SRS 10.11: one colour set for day and one for night.
class AppColors {
  const AppColors({
    required this.primary,
    required this.sunshine,
    required this.leaf,
    required this.amber,
    required this.coralSoft,
    required this.bubblegum,
    required this.sky,
    required this.background,
    required this.surface,
    required this.ink,
    required this.inkMuted,
    required this.border,
  });

  final Color primary;
  final Color sunshine;
  final Color leaf;
  final Color amber;
  final Color coralSoft;
  final Color bubblegum;
  final Color sky;
  final Color background;
  final Color surface;
  final Color ink;
  final Color inkMuted;
  final Color border;

  // ── Day palette ──
  static const AppColors day = AppColors(
    primary: Color(0xFF5B6CF0),
    sunshine: Color(0xFFFFC43D),
    leaf: Color(0xFF34C47C),
    amber: Color(0xFFFF9F2E),
    coralSoft: Color(0xFFFF8A7A),
    bubblegum: Color(0xFFFF7BAC),
    sky: Color(0xFF5CC8F5),
    background: Color(0xFFFFF9EF),
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF2A2A4A),
    inkMuted: Color(0xFF6B6B85),
    border: Color(0xFFE8E4F2),
  );

  // ── Night palette ──
  static const AppColors night = AppColors(
    primary: Color(0xFF8C98FF),
    sunshine: Color(0xFFFFD466),
    leaf: Color(0xFF5FE0A0),
    amber: Color(0xFFFFB866),
    coralSoft: Color(0xFFFFA394),
    bubblegum: Color(0xFFFF9CC2),
    sky: Color(0xFF7DD6FA),
    background: Color(0xFF141A33),
    surface: Color(0xFF1E2647),
    ink: Color(0xFFF2F4FF),
    inkMuted: Color(0xFFA9B0D6),
    border: Color(0xFF2E3A66),
  );

  /// Returns the night palette in dark mode, otherwise the day palette.
  static AppColors of(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return night;
    }
    return day;
  }
}
