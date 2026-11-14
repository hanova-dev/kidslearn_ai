import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/algorithms/camera_frame.dart';
import 'package:kidslearn_ai/algorithms/motion_timeline.dart';
import 'package:kidslearn_ai/algorithms/scene_choreographer.dart';
import 'package:kidslearn_ai/data/models/motion_directive.dart';
import 'package:kidslearn_ai/policy/motion_profile.dart';

MotionDirective directive(String camera, {String focus = 'center'}) {
  return MotionDirective(
    camera: camera,
    focus: focus,
    characterAction: 'idle_breathe',
    effect: 'none',
    mood: 'calm',
    cueWord: '',
  );
}

MotionTimeline timeline(
  String camera, {
  String focus = 'center',
  MotionProfile profile = MotionProfile.listener,
  bool rightToLeft = false,
  bool reduceMotion = false,
}) {
  return const SceneChoreographer().timelineFor(
    directive(camera, focus: focus),
    profile,
    rightToLeft: rightToLeft,
    reduceMotion: reduceMotion,
  );
}

void main() {
  // ── Each camera word gives the right start and end ──
  test('slow_zoom_in starts at the whole picture and ends closer', () {
    final moves = timeline('slow_zoom_in');

    expect(moves.cameraAt(0).scale, 1.0);
    expect(moves.cameraAt(8000).scale, closeTo(1.12, 0.0001));
    expect(moves.durationMs, 8000);
  });

  test('slow_zoom_out is the zoom in played backwards', () {
    final moves = timeline('slow_zoom_out');

    expect(moves.cameraAt(0).scale, closeTo(1.12, 0.0001));
    expect(moves.cameraAt(8000).scale, 1.0);
  });

  test('pan_left moves the picture to the right, so we look further left', () {
    final moves = timeline('pan_left');

    expect(moves.cameraAt(0).dx, lessThan(0));
    expect(moves.cameraAt(8000).dx, greaterThan(0));
    expect(moves.cameraAt(8000).dy, 0);
  });

  test('pan_up moves the picture down, so we look further up', () {
    final moves = timeline('pan_up');

    expect(moves.cameraAt(0).dy, lessThan(0));
    expect(moves.cameraAt(8000).dy, greaterThan(0));
  });

  test('static and unknown camera words give a still picture', () {
    expect(timeline('static').isStill, isTrue);
    expect(timeline('spin_fast').isStill, isTrue);
  });

  test('zooming in on the left shifts the picture right', () {
    final end = timeline('slow_zoom_in', focus: 'left').cameraAt(8000);

    expect(end.dx, closeTo(0.06, 0.0001));
    expect(end.dy, 0);
  });

  // ── Same input, same timeline (FR-MOTION-04) ──
  test('the same directive always gives the same timeline', () {
    final first = timeline('pan_right', profile: MotionProfile.reader);
    final second = timeline('pan_right', profile: MotionProfile.reader);

    for (var ms = 0; ms <= 4000; ms += 250) {
      expect(first.cameraAt(ms).dx, second.cameraAt(ms).dx);
      expect(first.cameraAt(ms).scale, second.cameraAt(ms).scale);
    }
  });

  // ── Right-to-left mirrors pans, not the focus point (FR-MOTION-10) ──
  test('right-to-left mirrors a pan', () {
    final normal = timeline('pan_left');
    final mirrored = timeline('pan_left', rightToLeft: true);

    expect(mirrored.cameraAt(0).dx, -normal.cameraAt(0).dx);
    expect(mirrored.cameraAt(8000).dx, -normal.cameraAt(8000).dx);
  });

  test(
    'right-to-left keeps the focus point, because the picture is not mirrored',
    () {
      final normal = timeline('slow_zoom_in', focus: 'left');
      final mirrored = timeline(
        'slow_zoom_in',
        focus: 'left',
        rightToLeft: true,
      );

      expect(mirrored.cameraAt(8000).dx, normal.cameraAt(8000).dx);
    },
  );

  // ── Policy limits: never past the profile, never showing an edge ──
  test('no camera word goes past the profile or shows the picture edge', () {
    for (final profile in [MotionProfile.listener, MotionProfile.reader]) {
      for (final camera in MotionDirective.cameras) {
        for (final focus in MotionDirective.focuses) {
          final moves = timeline(camera, focus: focus, profile: profile);
          for (var ms = 0; ms <= profile.cameraMs; ms += 100) {
            final frame = moves.cameraAt(ms);
            final edge = (frame.scale - 1) / 2 + 0.000001;
            expect(frame.scale, inInclusiveRange(1.0, profile.maxZoom));
            expect(frame.dx.abs(), lessThanOrEqualTo(edge));
            expect(frame.dy.abs(), lessThanOrEqualTo(edge));
          }
        }
      }
    }
  });

  test('the Reader move is shorter than the Listener move', () {
    expect(
      timeline('slow_zoom_in', profile: MotionProfile.reader).durationMs,
      lessThan(timeline('slow_zoom_in').durationMs),
    );
  });

  // ── Remove animations gives a still picture (FR-MOTION-06) ──
  test('reduce motion gives the whole picture, still', () {
    final moves = timeline('pan_left', reduceMotion: true);

    expect(moves.isStill, isTrue);
    expect(moves.cameraAt(3000).scale, 1.0);
    expect(moves.cameraAt(3000).dx, 0);
  });

  // ── The gentle start and stop ──
  test('the camera starts and stops slowly and is half way at the middle', () {
    expect(MotionTimeline.easeInOut(0), 0);
    expect(MotionTimeline.easeInOut(0.5), 0.5);
    expect(MotionTimeline.easeInOut(1), 1);
    expect(MotionTimeline.easeInOut(0.1), lessThan(0.1));
  });

  test('after the move ends the picture stays at the last frame', () {
    final moves = timeline('slow_zoom_in');

    expect(moves.cameraAt(20000).scale, moves.cameraAt(8000).scale);
  });

  test('between blends two frames', () {
    const to = CameraFrame(scale: 1.2, dx: 0.1, dy: -0.1);
    final half = CameraFrame.between(CameraFrame.plain, to, 0.5);

    expect(half.scale, closeTo(1.1, 0.0001));
    expect(half.dx, closeTo(0.05, 0.0001));
    expect(half.dy, closeTo(-0.05, 0.0001));
  });

  // ── The cue word: ease from where the camera is to the focus point (FR-MOTION-07) ──
  test(
    'the cue move starts where the camera is and ends on the focus point',
    () {
      const from = CameraFrame(scale: 1.03, dx: -0.01, dy: 0);
      final cue = const SceneChoreographer().cueTimelineFor(
        from,
        directive('pan_right', focus: 'left'),
        MotionProfile.listener,
        reduceMotion: false,
      );

      expect(cue.cameraAt(0).scale, 1.03);
      expect(cue.durationMs, MotionProfile.listener.cueMs);
      expect(cue.cameraAt(cue.durationMs).scale, closeTo(1.12, 0.0001));
      expect(cue.cameraAt(cue.durationMs).dx, closeTo(0.06, 0.0001));
    },
  );

  test('with reduce motion the cue word does not move the camera', () {
    final cue = const SceneChoreographer().cueTimelineFor(
      CameraFrame.plain,
      directive('slow_zoom_in', focus: 'right'),
      MotionProfile.listener,
      reduceMotion: true,
    );

    expect(cue.isStill, isTrue);
  });
}
