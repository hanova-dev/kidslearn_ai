import 'package:flutter/material.dart';

/// Lumi the fox, the app's mascot, drawn with simple shapes.
class LumiMascot extends StatelessWidget {
  const LumiMascot({super.key, this.size = 120});

  /// Width of the mascot; the height is 10% larger.
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.1,
      child: CustomPaint(painter: _LumiPainter()),
    );
  }
}

class _LumiPainter extends CustomPainter {
  static const Color orange = Color(0xFFF28A2E);
  static const Color cream = Color(0xFFFFF1DC);
  static const Color dark = Color(0xFF2A2A4A);
  static const Color pink = Color(0x66FF6F91);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100);
    final paint = Paint();

    // ── Shadow ──
    paint.color = const Color(0x1A000000);
    canvas.drawOval(_oval(50, 104, 50, 8), paint);

    // ── Tail ──
    canvas.save();
    canvas.translate(80, 74);
    canvas.rotate(-0.6);
    paint.color = orange;
    canvas.drawOval(_oval(0, 0, 22, 44), paint);
    paint.color = cream;
    canvas.drawOval(_oval(0, -16, 12, 14), paint);
    canvas.restore();

    // ── Body and belly ──
    paint.color = orange;
    canvas.drawOval(_oval(50, 80, 52, 46), paint);
    paint.color = cream;
    canvas.drawOval(_oval(50, 86, 30, 30), paint);

    // ── Ears ──
    paint.color = orange;
    canvas.drawPath(_triangle(22, 32, 30, 2, 46, 22), paint);
    canvas.drawPath(_triangle(54, 22, 70, 2, 78, 32), paint);
    paint.color = cream;
    canvas.drawPath(_triangle(29, 25, 32, 11, 40, 22), paint);
    canvas.drawPath(_triangle(60, 22, 68, 11, 71, 25), paint);

    // ── Head and muzzle ──
    paint.color = orange;
    canvas.drawOval(_oval(50, 42, 62, 54), paint);
    paint.color = cream;
    canvas.drawOval(_oval(50, 54, 30, 20), paint);

    // ── Cheeks ──
    paint.color = pink;
    canvas.drawCircle(const Offset(31, 51), 5, paint);
    canvas.drawCircle(const Offset(69, 51), 5, paint);

    // ── Eyes and nose ──
    paint.color = dark;
    canvas.drawCircle(const Offset(38, 41), 4.5, paint);
    canvas.drawCircle(const Offset(62, 41), 4.5, paint);
    canvas.drawOval(_oval(50, 49, 7, 5), paint);
    paint.color = Colors.white;
    canvas.drawCircle(const Offset(39.5, 39.5), 1.5, paint);
    canvas.drawCircle(const Offset(63.5, 39.5), 1.5, paint);

    // ── Smile ──
    final smile = Path()
      ..moveTo(45, 54)
      ..quadraticBezierTo(50, 59, 55, 54);
    final smilePaint = Paint()
      ..color = dark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(smile, smilePaint);
  }

  Rect _oval(double x, double y, double width, double height) {
    return Rect.fromCenter(center: Offset(x, y), width: width, height: height);
  }

  Path _triangle(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) {
    return Path()
      ..moveTo(x1, y1)
      ..lineTo(x2, y2)
      ..lineTo(x3, y3)
      ..close();
  }

  @override
  bool shouldRepaint(_LumiPainter oldDelegate) {
    return false;
  }
}
