import 'camera_frame.dart';

/// A camera frame the camera reaches at [atMs] milliseconds after the page opens.
class CameraKeyframe {
  const CameraKeyframe({required this.atMs, required this.frame});

  final int atMs;
  final CameraFrame frame;
}

/// The camera keyframes of one page, made by SceneChoreographer (M11, FR-MOTION-04).
class MotionTimeline {
  const MotionTimeline(this.keyframes);

  /// No motion: the whole picture for the whole page (FR-MOTION-06).
  static const MotionTimeline still = MotionTimeline([
    CameraKeyframe(atMs: 0, frame: CameraFrame.plain),
  ]);

  /// In time order; the first one is at 0 ms.
  final List<CameraKeyframe> keyframes;

  /// How long the motion lasts; after this the picture stays still.
  int get durationMs => keyframes.last.atMs;

  /// True when the camera never moves.
  bool get isStill => keyframes.length == 1;

  // ── The camera at any moment ──
  /// Finds the two keyframes around [ms] and blends them with a gentle start and stop.
  CameraFrame cameraAt(int ms) {
    if (ms <= keyframes.first.atMs) {
      return keyframes.first.frame;
    }
    for (var i = 1; i < keyframes.length; i++) {
      final before = keyframes[i - 1];
      final after = keyframes[i];
      if (ms <= after.atMs) {
        final t = (ms - before.atMs) / (after.atMs - before.atMs);
        return CameraFrame.between(before.frame, after.frame, easeInOut(t));
      }
    }
    return keyframes.last.frame;
  }

  // ── Slow at the start and at the end (no sudden moves, SRS 10) ──
  /// 0 → 0, 0.5 → 0.5, 1 → 1, but flat at both ends.
  static double easeInOut(double t) {
    return t * t * (3 - 2 * t);
  }
}
