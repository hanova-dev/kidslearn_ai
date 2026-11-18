import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/algorithms/frame_drop_detector.dart';

void main() {
  // ── Smooth frames never trip (NFR-PERF-05) ──
  test('fast frames never say too slow', () {
    final detector = FrameDropDetector();
    for (var i = 0; i < 500; i++) {
      expect(detector.addFrame(8), isFalse);
    }
    expect(detector.tooSlow, isFalse);
  });

  test('a few slow frames, like a page turn, are allowed', () {
    final detector = FrameDropDetector();
    for (var i = 0; i < 5; i++) {
      detector.addFrame(60);
    }
    for (var i = 0; i < 100; i++) {
      detector.addFrame(10);
    }
    expect(detector.tooSlow, isFalse);
  });

  // ── Many slow frames trip once (FR-MOTION-12) ──
  test('6 slow frames among the last 60 say too slow, once', () {
    final detector = FrameDropDetector();
    final answers = <bool>[];
    for (var i = 0; i < 60; i++) {
      var ms = 10;
      if (i % 10 == 0) {
        ms = 40;
      }
      answers.add(detector.addFrame(ms));
    }
    expect(answers.where((a) => a).length, 1);
    expect(detector.tooSlow, isTrue);
    expect(detector.addFrame(40), isFalse);
  });

  test('old slow frames leave the window and stop counting', () {
    final detector = FrameDropDetector();
    for (var i = 0; i < 5; i++) {
      detector.addFrame(50);
    }
    for (var i = 0; i < 60; i++) {
      detector.addFrame(10);
    }
    for (var i = 0; i < 5; i++) {
      detector.addFrame(50);
    }
    expect(detector.tooSlow, isFalse);
  });

  test('a frame of exactly the limit is not slow', () {
    final detector = FrameDropDetector();
    for (var i = 0; i < 60; i++) {
      detector.addFrame(FrameDropDetector.slowFrameMs);
    }
    expect(detector.tooSlow, isFalse);
  });
}
