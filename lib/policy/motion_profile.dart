/// How much the picture may move for one age group (M11, FR-MOTION-04, decision 034).
class MotionProfile {
  const MotionProfile({
    required this.cameraMs,
    required this.maxZoom,
    required this.effectCount,
    this.cueMs = 1500,
  });

  // ── The two profiles (the motion tunables live here) ──
  /// Ages 2–4: a slow 8-second move, up to 12% closer.
  static const MotionProfile listener = MotionProfile(
    cameraMs: 8000,
    maxZoom: 1.12,
    effectCount: 16,
  );

  /// Ages 5–7: a short 4-second move, up to 8% closer, so it is usually still before the child reads.
  static const MotionProfile reader = MotionProfile(
    cameraMs: 4000,
    maxZoom: 1.08,
    effectCount: 10,
  );

  /// How long one camera move lasts, in milliseconds; then the picture stays still.
  final int cameraMs;

  /// The largest zoom: 1.0 is the whole picture, 1.12 is 12% closer.
  final double maxZoom;

  /// How long the camera takes to ease to the focus point when the cue word is spoken.
  final int cueMs;

  /// How many leaves, drops, stars… an ambient effect draws at once (FR-MOTION-09).
  final int effectCount;
}
