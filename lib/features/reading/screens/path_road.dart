import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';

/// Where each circle sits on the path; used by the road painter and the circles.
class PathLayout {
  /// Space between two circles, from bottom to top.
  static const double rowHeight = 150;

  /// Room above the top circle for the "Tap to play!" bubble.
  static const double topSpace = 190;

  /// Room below the first circle for the Home button.
  static const double bottomSpace = 150;

  /// The road zig-zags between these places (part of the screen width).
  static const List<double> xFractions = [0.30, 0.68, 0.40, 0.70];

  /// Height the path needs for [count] circles.
  static double heightFor(int count) {
    return topSpace + bottomSpace + (count - 1) * rowHeight;
  }

  /// Centre of circle number [index] (0 = oldest, at the bottom).
  static Offset centreOf(int index, double width, double height) {
    final x = width * xFractions[index % xFractions.length];
    final y = height - bottomSpace - index * rowHeight;
    return Offset(x, y);
  }
}

/// Paints the winding road with yellow dots between the circles (design p15).
class PathRoadPainter extends CustomPainter {
  PathRoadPainter({required this.centres, required this.colors});

  final List<Offset> centres;
  final AppColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    if (centres.length < 2) {
      return;
    }

    // ── Road shape: an S-curve from each circle to the next ──
    final road = Path()..moveTo(centres[0].dx, centres[0].dy);
    for (var i = 1; i < centres.length; i++) {
      final from = centres[i - 1];
      final to = centres[i];
      final middleY = (from.dy + to.dy) / 2;
      road.cubicTo(from.dx, middleY, to.dx, middleY, to.dx, to.dy);
    }

    // ── Wide pale road ──
    final roadPaint = Paint()
      ..color = colors.surface.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(road, roadPaint);

    // ── Yellow dots along the road ──
    final dotPaint = Paint()..color = colors.sunshine;
    for (final metric in road.computeMetrics()) {
      for (double distance = 0; distance < metric.length; distance += 24) {
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          canvas.drawCircle(tangent.position, 4, dotPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(PathRoadPainter oldDelegate) {
    return oldDelegate.centres != centres || oldDelegate.colors != colors;
  }
}
