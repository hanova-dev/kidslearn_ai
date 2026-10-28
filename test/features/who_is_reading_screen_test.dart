import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/data/models/age_group.dart';
import 'package:kidslearn_ai/data/models/child_profile.dart';

import '../fakes/fake_auth_repository.dart';
import '../fakes/fake_child_repository.dart';
import '../helpers/test_app.dart';

ChildProfile makeChild(String name, AgeGroup ageGroup, String buddyId) {
  return ChildProfile(
    id: 'child-$name',
    parentId: 'parent-1',
    name: name,
    buddyId: buddyId,
    ageGroup: ageGroup,
    language: 'en',
    starBalance: 0,
    readingLevel: 1,
    createdAt: DateTime(2026, 10, 27),
  );
}

void main() {
  // ── Lists the children ──
  testWidgets('shows one card per child with the age-group title', (
    tester,
  ) async {
    final children = FakeChildRepository()
      ..saved.add(makeChild('Fatima', AgeGroup.reader, 'mango'))
      ..saved.add(makeChild('Zayan', AgeGroup.listener, 'leafy'));

    usePhoneScreen(tester);
    await tester.pumpWidget(
      buildTestApp(
        auth: FakeAuthRepository(signedInUserId: 'parent-1'),
        children: children,
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Fatima'), findsOneWidget);
    expect(find.text('Growing Reader'), findsOneWidget);
    expect(find.text('Zayan'), findsOneWidget);
    expect(find.text('Little Listener'), findsOneWidget);
  });

  // ── Picking a child makes them active (FR-AUTH-05) ──
  testWidgets('tapping a child opens their path with their name', (
    tester,
  ) async {
    final children = FakeChildRepository()
      ..saved.add(makeChild('Fatima', AgeGroup.reader, 'mango'));

    usePhoneScreen(tester);
    await tester.pumpWidget(
      buildTestApp(
        auth: FakeAuthRepository(signedInUserId: 'parent-1'),
        children: children,
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.tap(find.text('Fatima'));
    await tester.pumpAndSettle();

    expect(find.text('Hi, Fatima!'), findsOneWidget);

    await tester.tap(find.byTooltip('Home'));
    await tester.pumpAndSettle();
    expect(find.text("Who's reading today?"), findsOneWidget);
  });
}
