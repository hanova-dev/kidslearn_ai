/// Where the camera is at one moment: how close, and how far the picture is shifted (M11, FR-MOTION-04).
class CameraFrame {
  const CameraFrame({required this.scale, required this.dx, required this.dy});

  /// The whole picture, not moved.
  static const CameraFrame plain = CameraFrame(scale: 1, dx: 0, dy: 0);

  /// 1.0 is the whole picture; 1.1 is 10% closer.
  final double scale;

  /// Shift to the right as a share of the picture width (0.05 = 5%); negative is left.
  final double dx;

  /// Shift down as a share of the picture height; negative is up.
  final double dy;

  // ── A frame part of the way from one frame to another ──
  /// [t] is 0 at [from] and 1 at [to].
  static CameraFrame between(CameraFrame from, CameraFrame to, double t) {
    return CameraFrame(
      scale: from.scale + (to.scale - from.scale) * t,
      dx: from.dx + (to.dx - from.dx) * t,
      dy: from.dy + (to.dy - from.dy) * t,
    );
  }
}
