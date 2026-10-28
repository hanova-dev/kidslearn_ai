import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/core/widgets/lumi_mascot.dart';

import '../fakes/fake_auth_repository.dart';
import '../helpers/test_app.dart';

void main() {
  // ── Day mode ──
  testWidgets('splash shows Lumi, the app name and the tagline', (
    tester,
  ) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(buildTestApp(auth: FakeAuthRepository()));

    expect(find.byType(LumiMascot), findsOneWidget);
    expect(find.text('KidsLearn'), findsOneWidget);
    expect(find.text('Stories that grow with your child'), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 2));
  });

  // ── Night mode ──
  testWidgets('splash uses the dark theme when the phone is in dark mode', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    usePhoneScreen(tester);
    await tester.pumpWidget(buildTestApp(auth: FakeAuthRepository()));

    final context = tester.element(find.text('KidsLearn'));
    expect(Theme.of(context).brightness, Brightness.dark);

    await tester.pumpAndSettle(const Duration(seconds: 2));
  });
}
