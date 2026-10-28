import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/app/app_colors.dart';
import 'package:kidslearn_ai/app/theme.dart';

void main() {
  // ── Token values from SRS 10.11 ──
  test('day and night tokens match the SRS table', () {
    expect(AppColors.day.primary, const Color(0xFF5B6CF0));
    expect(AppColors.night.primary, const Color(0xFF8C98FF));
    expect(AppColors.day.coralSoft, const Color(0xFFFF8A7A));
    expect(AppColors.night.background, const Color(0xFF141A33));
  });

  // ── Theme uses the tokens ──
  test('themes use the token background colours', () {
    expect(AppTheme.day().scaffoldBackgroundColor, AppColors.day.background);
    expect(
      AppTheme.night().scaffoldBackgroundColor,
      AppColors.night.background,
    );
  });
}
