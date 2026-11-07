import 'dart:math';

import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';

/// Paints still confetti and three big stars above the buddy (design p22).
class CelebrationPainter extends CustomPainter {
  CelebrationPainter({required this.colors});

  final AppColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint();

    // ── Confetti: small dots and pieces at fixed places ──
    final confettiColors = [
      colors.leaf,
      colors.primary,
      colors.bubblegum,
      colors.sky,
      colors.sunshine,
    ];
    const places = [
      [0.12, 0.10],
      [0.30, 0.22],
      [0.62, 0.20],
      [0.86, 0.14],
      [0.08, 0.42],
      [0.24, 0.52],
      [0.78, 0.40],
      [0.92, 0.55],
      [0.44, 0.08],
      [0.70, 0.60],
    ];
    for (var i = 0; i < places.length; i++) {
      paint.color = confettiColors[i % confettiColors.length];
      final centre = Offset(w * places[i][0], h * places[i][1]);
      if (i.isEven) {
        canvas.drawCircle(centre, 7, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: centre, width: 18, height: 9),
            const Radius.circular(3),
          ),
          paint,
        );
      }
    }

    // ── Three stars, the middle one bigger ──
    paint.color = colors.sunshine;
    canvas.drawPath(_star(Offset(w * 0.32, h * 0.36), 30), paint);
    canvas.drawPath(_star(Offset(w * 0.50, h * 0.24), 42), paint);
    canvas.drawPath(_star(Offset(w * 0.68, h * 0.36), 30), paint);
  }

  /// A 5-point star: 10 corners, going round, outer and inner in turn.
  Path _star(Offset centre, double outerRadius) {
    final innerRadius = outerRadius * 0.45;
    final path = Path();
    for (var i = 0; i < 10; i++) {
      var radius = outerRadius;
      if (i.isOdd) {
        radius = innerRadius;
      }
      final angle = -pi / 2 + i * pi / 5;
      final point = Offset(
        centre.dx + radius * cos(angle),
        centre.dy + radius * sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(CelebrationPainter oldDelegate) {
    return oldDelegate.colors != colors;
  }
}
