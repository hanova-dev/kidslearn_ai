import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/algorithms/ambient_effect.dart';
import 'package:kidslearn_ai/data/models/motion_directive.dart';

void main() {
  // ── No effect: "none" and unknown words draw nothing (FR-MOTION-09) ──
  test('"none" and an unknown word give no particles', () {
    expect(AmbientEffect('none', count: 16).isNone, isTrue);
    expect(AmbientEffect('fireworks', count: 16).statesAt(500), isEmpty);
  });

  test('every effect word except "none" can be drawn', () {
    for (final word in MotionDirective.effects) {
      expect(AmbientEffect(word, count: 4).isNone, word == 'none');
    }
  });

  test('the count from the profile is the number of particles', () {
    expect(AmbientEffect('snow', count: 16).statesAt(0).length, 16);
    expect(AmbientEffect('snow', count: 10).statesAt(0).length, 10);
  });

  // ── Same seed, same page ──
  test('the same effect looks the same every time', () {
    final first = AmbientEffect('rain', count: 5).statesAt(1234);
    final second = AmbientEffect('rain', count: 5).statesAt(1234);
    for (var i = 0; i < first.length; i++) {
      expect(first[i].x, second[i].x);
      expect(first[i].y, second[i].y);
    }
  });

  // ── Moves of each kind ──
  test('snow falls down and bubbles rise up, then start again', () {
    final snow = AmbientEffect('snow', count: 16);
    final bubbles = AmbientEffect('bubbles', count: 16);
    for (var i = 0; i < 16; i++) {
      var fell = snow.statesAt(500)[i].y - snow.statesAt(0)[i].y;
      var rose = bubbles.statesAt(0)[i].y - bubbles.statesAt(500)[i].y;
      if (fell < 0) {
        fell += 1.2;
      }
      if (rose < 0) {
        rose += 1.2;
      }
      expect(fell, closeTo(1.2 * 500 / 10000, 0.0001));
      expect(rose, closeTo(1.2 * 500 / 8000, 0.0001));
    }
  });

  test('every particle stays near the picture, opacity between 0 and 1', () {
    for (final word in MotionDirective.effects) {
      final effect = AmbientEffect(word, count: 16);
      for (var ms = 0; ms < 20000; ms += 250) {
        for (final p in effect.statesAt(ms)) {
          expect(p.x, inInclusiveRange(-0.15, 1.15));
          expect(p.y, inInclusiveRange(-0.15, 1.15));
          expect(p.opacity, inInclusiveRange(0.0, 1.0));
        }
      }
    }
  });

  // ── Calm: nothing flashes 3 or more times a second (NFR-USE-06) ──
  test(
    'stars and sparkles glow slowly, butterflies beat below 3 per second',
    () {
      expect(AmbientEffect.cycleMs['stars_twinkle']!, greaterThan(1000 / 3));
      expect(AmbientEffect.cycleMs['sparkles']!, greaterThan(1000 / 3));
      expect(AmbientEffect.wingBeatsPerSecond, lessThan(3));
    },
  );

  test('a twinkling star never fully disappears', () {
    final stars = AmbientEffect('stars_twinkle', count: 8);
    for (var ms = 0; ms < 3000; ms += 100) {
      for (final p in stars.statesAt(ms)) {
        expect(p.opacity, greaterThanOrEqualTo(0.3));
      }
    }
  });
}
