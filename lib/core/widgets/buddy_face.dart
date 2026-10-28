import 'package:flutter/material.dart';

import '../constants/buddies.dart';

/// A buddy's round coloured face with a smile (designs p4, p6, p12).
class BuddyFace extends StatelessWidget {
  const BuddyFace({super.key, required this.buddy, this.size = 64});

  final Buddy buddy;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${buddy.name} the ${buddy.animal}',
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _FacePainter(buddy.color)),
      ),
    );
  }
}

class _FacePainter extends CustomPainter {
  _FacePainter(this.color);

  final Color color;
  static const Color dark = Color(0xFF2A2A4A);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100);

    // ── Face ──
    canvas.drawCircle(const Offset(50, 50), 50, Paint()..color = color);

    // ── Eyes ──
    final eyePaint = Paint()..color = dark;
    canvas.drawCircle(const Offset(38, 44), 4.5, eyePaint);
    canvas.drawCircle(const Offset(62, 44), 4.5, eyePaint);

    // ── Smile ──
    final smile = Path()
      ..moveTo(38, 58)
      ..quadraticBezierTo(50, 70, 62, 58);
    final smilePaint = Paint()
      ..color = dark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(smile, smilePaint);
  }

  @override
  bool shouldRepaint(_FacePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
