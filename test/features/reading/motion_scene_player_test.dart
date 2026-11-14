import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/data/models/motion_directive.dart';
import 'package:kidslearn_ai/features/reading/screens/motion_scene_player.dart';
import 'package:kidslearn_ai/policy/motion_profile.dart';

const zoomIn = MotionDirective(
  camera: 'slow_zoom_in',
  focus: 'center',
  characterAction: 'idle_breathe',
  effect: 'none',
  mood: 'happy',
  cueWord: '',
);

Widget player({bool settled = false, bool noAnimations = false}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: noAnimations),
      child: Center(
        child: SizedBox(
          width: 300,
          height: 200,
          child: MotionScenePlayer(
            directive: zoomIn,
            profile: MotionProfile.listener,
            settled: settled,
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
}
