/// Says when the phone draws too many slow frames to keep the effects (M11, FR-MOTION-12, NFR-PERF-05).
class FrameDropDetector {
  // ── The tunables ──
  /// A frame slower than this (milliseconds) missed the screen; 33 ms is two frames at 60 per second.
  static const int slowFrameMs = 33;

  /// How many of the latest frames we look at.
  static const int windowSize = 60;

  /// This many slow frames inside the window means "too slow" (10%).
  static const int maxSlowFrames = 6;

  final List<bool> _latest = [];
  bool _tooSlow = false;

  /// True after the detector has tripped; it stays true.
  bool get tooSlow => _tooSlow;

  // ── Add one frame; true only at the moment it trips ──
  /// Adds a frame that took [frameMs] milliseconds to build and draw.
  bool addFrame(int frameMs) {
    if (_tooSlow) {
      return false;
    }
    _latest.add(frameMs > slowFrameMs);
    if (_latest.length > windowSize) {
      _latest.removeAt(0);
    }
    var slow = 0;
    for (final isSlow in _latest) {
      if (isSlow) {
        slow++;
      }
    }
    if (slow >= maxSlowFrames) {
      _tooSlow = true;
      return true;
    }
    return false;
  }
}
