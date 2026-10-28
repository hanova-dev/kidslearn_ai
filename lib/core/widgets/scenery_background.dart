import 'package:flutter/material.dart';

import '../../app/app_colors.dart';

/// Sky, sun or moon, cloud and rolling hills behind [child] (day or night).
class SceneryBackground extends StatelessWidget {
  const SceneryBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isNight = Theme.of(context).brightness == Brightness.dark;
    return SizedBox.expand(
      child: CustomPaint(
        painter: _SceneryPainter(isNight: isNight),
        child: child,
      ),
    );
  }
}

class _SceneryPainter extends CustomPainter {
  _SceneryPainter({required this.isNight});

  final bool isNight;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint();

    // ── Sky ──
    paint.color = isNight
        ? AppColors.night.background
        : const Color(0xFFD4ECFB);
    canvas.drawRect(Offset.zero & size, paint);

    // ── Sun or moon ──
    paint.color = isNight ? const Color(0xFFF5EFD0) : AppColors.day.sunshine;
    canvas.drawCircle(Offset(w * 0.78, h * 0.12), w * 0.09, paint);

    // ── Cloud ──
    paint.color = isNight ? AppColors.night.border : Colors.white;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.22, h * 0.17),
        width: w * 0.26,
        height: h * 0.035,
      ),
      paint,
    );

    // ── Stars (night only) ──
    if (isNight) {
      paint.color = AppColors.night.sunshine;
      canvas.drawCircle(Offset(w * 0.12, h * 0.09), 2.5, paint);
      canvas.drawCircle(Offset(w * 0.48, h * 0.21), 2, paint);
      canvas.drawCircle(Offset(w * 0.62, h * 0.07), 2, paint);
    }

    // ── Hills ──
    _drawHill(
      canvas,
      size,
      0.68,
      isNight ? const Color(0xFF232D5C) : const Color(0xFFA5DDB0),
    );
    _drawHill(
      canvas,
      size,
      0.77,
      isNight ? const Color(0xFF1E2752) : const Color(0xFF7CCB91),
    );
    _drawHill(
      canvas,
      size,
      0.87,
      isNight ? const Color(0xFF1A2249) : const Color(0xFF57B97A),
    );
  }

  void _drawHill(Canvas canvas, Size size, double topFraction, Color color) {
    final w = size.width;
    final h = size.height;
    final top = h * topFraction;
    final path = Path()
      ..moveTo(0, top)
      ..quadraticBezierTo(w * 0.3, top - h * 0.06, w * 0.6, top)
      ..quadraticBezierTo(w * 0.85, top + h * 0.04, w, top - h * 0.04)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_SceneryPainter oldDelegate) {
    return oldDelegate.isNight != isNight;
  }
}
