import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_auth_repository.dart';
import '../helpers/test_app.dart';

void main() {
  // ── Signed out: splash goes to log in (FR-AUTH-03) ──
  testWidgets('a signed-out parent lands on the log in screen', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(buildTestApp(auth: FakeAuthRepository()));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Welcome, grown-up!'), findsOneWidget);
  });

  // ── Saved session: app opens in child space (FR-AUTH-06, SRS D7) ──
  testWidgets('a saved session opens Who\'s reading, not the parent area', (
    tester,
  ) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      buildTestApp(auth: FakeAuthRepository(signedInUserId: 'parent-1')),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text("Who's reading today?"), findsOneWidget);
    expect(find.text('Your readers'), findsNothing);
  });

  // ── Parent area is guarded by the gate (FR-AUTH-04) ──
  testWidgets('Grown-ups button leads to the gate, not parent home', (
    tester,
  ) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      buildTestApp(auth: FakeAuthRepository(signedInUserId: 'parent-1')),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.tap(find.text('Grown-ups'));
    await tester.pumpAndSettle();

    expect(find.text('Grown-ups only'), findsOneWidget);
    expect(find.text('Your readers'), findsNothing);
  });
}
