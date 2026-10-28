import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/data/models/age_group.dart';

import '../fakes/fake_auth_repository.dart';
import '../fakes/fake_child_repository.dart';
import '../helpers/test_app.dart';

void main() {
  // ── Open Add child: Who's reading → (unlocked) parent home → Add a reader ──
  Future<void> openAddChild(
    WidgetTester tester,
    FakeChildRepository children,
  ) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      buildTestApp(
        auth: FakeAuthRepository(signedInUserId: 'parent-1'),
        children: children,
        parentUnlocked: true,
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.text('Grown-ups'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add a reader'));
    await tester.pumpAndSettle();
  }

  Future<void> tapStart(WidgetTester tester) async {
    await tester.tap(find.text('Start the adventure'));
    await tester.pumpAndSettle();
  }

  // ── Missing buddy ──
  testWidgets('asks for a buddy before saving', (tester) async {
    final children = FakeChildRepository();
    await openAddChild(tester, children);
    await tester.enterText(find.byType(TextFormField), 'Fatima');

    await tapStart(tester);

    expect(find.text('Please pick a buddy.'), findsOneWidget);
    expect(children.saved, isEmpty);
  });

  // ── Old messages go away once fixed (emulator test 28 Oct) ──
  testWidgets('messages disappear when the name and buddy are fixed', (
    tester,
  ) async {
    await openAddChild(tester, FakeChildRepository());
    await tapStart(tester);
    expect(find.text("Please type your child's name."), findsOneWidget);
    expect(find.text('Please pick a buddy.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Ali');
    await tester.tap(find.bySemanticsLabel('Mango the fox'));
    await tester.pump();

    expect(find.text("Please type your child's name."), findsNothing);
    expect(find.text('Please pick a buddy.'), findsNothing);
  });

  // ── Full form saves and shows the child ──
  testWidgets('a full form saves the child and shows it on parent home', (
    tester,
  ) async {
    final children = FakeChildRepository();
    await openAddChild(tester, children);
    await tester.enterText(find.byType(TextFormField), 'Fatima');
    await tester.tap(find.bySemanticsLabel('Mango the fox'));
    await tester.tap(find.text('Growing Reader'));
    await tester.pump();

    await tapStart(tester);

    expect(children.saved.length, 1);
    expect(children.saved.first.buddyId, 'mango');
    expect(children.saved.first.ageGroup, AgeGroup.reader);
    expect(find.text('Your readers'), findsOneWidget);
    expect(find.text('Fatima'), findsOneWidget);
    expect(find.text('Growing Reader · English'), findsOneWidget);
  });

  // ── Save error ──
  testWidgets('a save error shows a friendly message', (tester) async {
    final children = FakeChildRepository(failOnSave: true);
    await openAddChild(tester, children);
    await tester.enterText(find.byType(TextFormField), 'Zayan');
    await tester.tap(find.bySemanticsLabel('Leafy the turtle'));
    await tester.tap(find.text('Little Listener'));
    await tester.pump();

    await tapStart(tester);

    expect(find.text('Could not save. Please try again.'), findsOneWidget);
    expect(find.text('Who is our new reader?'), findsOneWidget);
  });
}
