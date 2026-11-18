import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/data/models/motion_directive.dart';
import 'package:kidslearn_ai/features/reading/screens/ambient_effect_layer.dart';
import 'package:kidslearn_ai/features/reading/screens/ambient_effect_painter.dart';
import 'package:kidslearn_ai/features/reading/screens/motion_scene_player.dart';
import 'package:kidslearn_ai/policy/motion_profile.dart';

MotionDirective zoomInWith(String effect) {
  return MotionDirective(
    camera: 'slow_zoom_in',
    focus: 'center',
    characterAction: 'idle_breathe',
    effect: effect,
    mood: 'happy',
    cueWord: '',
  );
}

Widget player({
  bool settled = false,
  bool noAnimations = false,
  bool cueHeard = false,
  String effect = 'none',
}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: noAnimations),
      child: Center(
        child: SizedBox(
          width: 300,
          height: 200,
          child: MotionScenePlayer(
            directive: zoomInWith(effect),
            profile: MotionProfile.listener,
            settled: settled,
            cueHeard: cueHeard,
            child: const ColoredBox(color: Colors.green),
          ),
        ),
      ),
    ),
  );
}

double scaleNow(WidgetTester tester) {
  final transform = tester.widget<Transform>(
    find.descendant(
      of: find.byType(MotionScenePlayer),
      matching: find.byType(Transform),
    ),
  );
  return transform.transform.getMaxScaleOnAxis();
}

int effectClock(WidgetTester tester) {
  final paint = tester.widget<CustomPaint>(
    find.descendant(
      of: find.byType(AmbientEffectLayer),
      matching: find.byType(CustomPaint),
    ),
  );
  final painter = paint.painter! as AmbientEffectPainter;
  return painter.clock.value;
}

void main() {
  // ── The picture moves along the timeline (FR-MOTION-04) ──
  testWidgets('the picture zooms in slowly and then stays still', (
    tester,
  ) async {
    await tester.pumpWidget(player());
    expect(scaleNow(tester), closeTo(1.0, 0.0001));

    await tester.pump(const Duration(seconds: 4));
    expect(scaleNow(tester), closeTo(1.06, 0.001));

    await tester.pump(const Duration(seconds: 4));
    expect(scaleNow(tester), closeTo(1.12, 0.001));

    await tester.pump(const Duration(seconds: 5));
    expect(scaleNow(tester), closeTo(1.12, 0.001));
  });

  // ── Reader Mode: the camera stops when the microphone starts (FR-MOTION-05) ──
  testWidgets('settled stops the camera where it is', (tester) async {
    await tester.pumpWidget(player());
    await tester.pump(const Duration(seconds: 2));

    await tester.pumpWidget(player(settled: true));
    final stoppedAt = scaleNow(tester);
    await tester.pump(const Duration(seconds: 6));

    expect(stoppedAt, greaterThan(1.0));
    expect(scaleNow(tester), stoppedAt);
  });

  // ── Remove animations shows the still picture (FR-MOTION-06) ──
  testWidgets('with Remove animations on, the picture never moves', (
    tester,
  ) async {
    await tester.pumpWidget(player(noAnimations: true));
    await tester.pump(const Duration(seconds: 4));

    expect(scaleNow(tester), 1.0);
    expect(tester.hasRunningAnimations, isFalse);
  });

  // ── The cue word eases the camera to the focus point (FR-MOTION-07) ──
  testWidgets('the cue word ends the move early on the focus point', (
    tester,
  ) async {
    await tester.pumpWidget(player());
    await tester.pump(const Duration(seconds: 1));

    await tester.pumpWidget(player(cueHeard: true));
    await tester.pump(const Duration(milliseconds: 1600));

    expect(scaleNow(tester), closeTo(1.12, 0.001));
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('in Reader Mode while reading the cue word is ignored', (
    tester,
  ) async {
    await tester.pumpWidget(player());
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(player(settled: true));
    final stoppedAt = scaleNow(tester);

    await tester.pumpWidget(player(settled: true, cueHeard: true));
    await tester.pump(const Duration(seconds: 2));

    expect(scaleNow(tester), stoppedAt);
  });

  // ── Ambient effect over the picture (FR-MOTION-09) ──
  testWidgets('a page with snow draws the effect and keeps it moving', (
    tester,
  ) async {
    await tester.pumpWidget(player(effect: 'snow'));
    await tester.pump(const Duration(seconds: 10));
    final before = effectClock(tester);
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(AmbientEffectLayer), findsOneWidget);
    expect(effectClock(tester), greaterThan(before));
  });

  testWidgets('a page with no effect draws no effect layer', (tester) async {
    await tester.pumpWidget(player());

    expect(find.byType(AmbientEffectLayer), findsNothing);
  });

  testWidgets('with Remove animations on, there is no effect', (tester) async {
    await tester.pumpWidget(player(effect: 'snow', noAnimations: true));
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(AmbientEffectLayer), findsNothing);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('settled freezes the effect where it is', (tester) async {
    await tester.pumpWidget(player(effect: 'snow'));
    await tester.pump(const Duration(seconds: 2));

    await tester.pumpWidget(player(effect: 'snow', settled: true));
    final frozenAt = effectClock(tester);
    await tester.pump(const Duration(seconds: 3));

    expect(frozenAt, greaterThan(0));
    expect(effectClock(tester), frozenAt);
    expect(tester.hasRunningAnimations, isFalse);
  });

  // ── The picture always fills the whole box, with or without an effect ──
  testWidgets('a small picture is stretched to fill the player', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 300,
            height: 200,
            child: MotionScenePlayer(
              directive: zoomInWith('rain'),
              profile: MotionProfile.reader,
              child: const SizedBox(key: Key('picture'), width: 50, height: 50),
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byKey(const Key('picture'))),
      const Size(300, 200),
    );
  });
}
