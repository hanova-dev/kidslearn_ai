import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_auth_repository.dart';
import '../helpers/test_app.dart';

void main() {
  // ── Open the gate from Who's reading ──
  Future<void> openGate(WidgetTester tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      buildTestApp(auth: FakeAuthRepository(signedInUserId: 'parent-1')),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.text('Grown-ups'));
    await tester.pumpAndSettle();
  }

  // ── Read the sum on screen, e.g. "14 + 9 = ?" → 23 ──
  int answerOnScreen(WidgetTester tester) {
    final text = tester.widget<Text>(find.textContaining(' + ')).data!;
    final parts = text.replaceAll(' = ?', '').split(' + ');
    return int.parse(parts[0]) + int.parse(parts[1]);
  }

  Future<void> typeAnswer(WidgetTester tester, int answer) async {
    for (final digit in answer.toString().split('')) {
      await tester.tap(find.byKey(Key('key-$digit')));
    }
    await tester.tap(find.byKey(const Key('key-ok')));
    await tester.pumpAndSettle();
  }

  // ── Wrong answer ──
  testWidgets('a wrong answer stays locked and asks a new question', (
    tester,
  ) async {
    await openGate(tester);
    final wrong = answerOnScreen(tester) + 1;

    await typeAnswer(tester, wrong);

    expect(find.text('Not quite. Try this one.'), findsOneWidget);
    expect(find.text('Grown-ups only'), findsOneWidget);
  });

  // ── Right answer ──
  testWidgets('the right answer opens parent home', (tester) async {
    await openGate(tester);

    await typeAnswer(tester, answerOnScreen(tester));

    expect(find.text('Your readers'), findsOneWidget);
  });

  // ── Child mode locks again ──
  testWidgets('Go to child mode locks the parent area again', (tester) async {
    await openGate(tester);
    await typeAnswer(tester, answerOnScreen(tester));

    await tester.tap(find.byTooltip('Profile menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Go to child mode'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Grown-ups'));
    await tester.pumpAndSettle();

    expect(find.text('Grown-ups only'), findsOneWidget);
  });

  // ── Back to stories ──
  testWidgets('Back to stories returns to Who\'s reading', (tester) async {
    await openGate(tester);

    await tester.tap(find.text('Back to stories'));
    await tester.pumpAndSettle();

    expect(find.text("Who's reading today?"), findsOneWidget);
  });
}
