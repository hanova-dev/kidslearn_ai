import 'dart:math';

import 'package:flutter/material.dart';

import '../../../algorithms/ambient_effect.dart';
import '../../../app/app_colors.dart';

/// Draws the particles of one ambient effect in code: no image files (FR-MOTION-09).
class AmbientEffectPainter extends CustomPainter {
  AmbientEffectPainter({
    required this.effect,
    required this.clock,
    required this.colors,
  }) : super(repaint: clock);

  final AmbientEffect effect;

  /// Milliseconds since the page opened; every change repaints.
  final ValueNotifier<int> clock;
  final AppColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final unit = size.shortestSide / 30;
    for (final particle in effect.statesAt(clock.value)) {
      final centre = Offset(particle.x * size.width, particle.y * size.height);
      final radius = unit * particle.size;
      switch (effect.name) {
        case 'falling_leaves':
          _leaf(canvas, paint, centre, radius, particle);
        case 'rain':
          _drop(canvas, paint, centre, radius, particle);
        case 'snow':
          paint.color = Colors.white.withValues(alpha: particle.opacity);
          canvas.drawCircle(centre, radius * 0.6, paint);
        case 'bubbles':
          _bubble(canvas, paint, centre, radius, particle);
        case 'stars_twinkle':
          paint.color = colors.sunshine.withValues(alpha: particle.opacity);
          canvas.drawPath(_star(centre, radius * 0.9), paint);
        case 'sparkles':
          paint.color = Colors.white.withValues(alpha: particle.opacity);
          canvas.drawPath(_star(centre, radius * 0.6), paint);
        case 'butterflies':
          _butterfly(canvas, paint, centre, radius, particle);
      }
    }
  }

  // ── Leaf: a tilted oval in autumn colours ──
  void _leaf(Canvas canvas, Paint paint, Offset c, double r, ParticleState p) {
    paint.color = (p.size > 0.75 ? colors.amber : colors.sunshine).withValues(
      alpha: p.opacity,
    );
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(p.turn * 0.8);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: r * 1.6, height: r * 0.8),
      paint,
    );
    canvas.restore();
  }

  // ── Raindrop: a short slanted line ──
  void _drop(Canvas canvas, Paint paint, Offset c, double r, ParticleState p) {
    paint
      ..color = colors.sky.withValues(alpha: p.opacity)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(c, c + Offset(-r * 0.3, r * 1.5), paint);
  }

  // ── Bubble: a thin ring with a small shine ──
  void _bubble(
    Canvas canvas,
    Paint paint,
    Offset c,
    double r,
    ParticleState p,
  ) {
    paint
      ..color = Colors.white.withValues(alpha: p.opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(c, r, paint);
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(c + Offset(-r * 0.35, -r * 0.35), r * 0.2, paint);
  }

  // ── Butterfly: a thin body, big upper wings and small lower wings that beat ──
  void _butterfly(
    Canvas canvas,
    Paint paint,
    Offset c,
    double r,
    ParticleState p,
  ) {
    final size = r * 1.6;
    final open = 0.45 + 0.55 * p.turn.abs();
    paint.color = (p.size > 0.75 ? colors.bubblegum : colors.sky).withValues(
      alpha: p.opacity,
    );
    for (final side in [-1.0, 1.0]) {
      final upper = Rect.fromCenter(
        center: c + Offset(side * size * 0.45 * open, -size * 0.25),
        width: size * 0.9 * open,
        height: size,
      );
      final lower = Rect.fromCenter(
        center: c + Offset(side * size * 0.35 * open, size * 0.35),
        width: size * 0.6 * open,
        height: size * 0.6,
      );
      canvas.drawOval(upper, paint);
      canvas.drawOval(lower, paint);
    }
    paint
      ..color = colors.ink.withValues(alpha: p.opacity)
      ..strokeWidth = size * 0.12
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      c + Offset(0, -size * 0.45),
      c + Offset(0, size * 0.5),
      paint,
    );
  }

  /// A 4-point star: 8 corners, outer and inner in turn.
  Path _star(Offset centre, double outerRadius) {
    final path = Path();
    for (var i = 0; i < 8; i++) {
      var radius = outerRadius;
      if (i.isOdd) {
        radius = outerRadius * 0.35;
      }
      final angle = -pi / 2 + i * pi / 4;
      final point = centre + Offset(radius * cos(angle), radius * sin(angle));
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
  bool shouldRepaint(AmbientEffectPainter oldDelegate) {
    return oldDelegate.effect != effect || oldDelegate.colors != colors;
  }
}
