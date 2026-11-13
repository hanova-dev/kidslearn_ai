import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kidslearn_ai/core/widgets/child_scaffold.dart';

import '../helpers/test_app.dart';

void main() {
  // ── A tiny app with one child screen and the Who's reading page ──
  Future<void> openScreen(
    WidgetTester tester, {
    required VoidCallback onBack,
    Widget? topRight,
  }) async {
    final router = GoRouter(
      initialLocation: '/child',
      routes: [
        GoRoute(
          path: '/child',
          builder: (context, state) => ChildScaffold(
            onBack: onBack,
            topRight: topRight,
            body: const Center(child: Text('Body')),
          ),
        ),
        GoRoute(
          path: '/who',
          builder: (context, state) => const Text('Who is reading'),
        ),
      ],
    );
    usePhoneScreen(tester);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  // ── Fixed places (SRS 10.9, D5, FR-HCI-04) ──
  testWidgets('Back is top-left and Home is bottom-centre', (tester) async {
    await openScreen(tester, onBack: () {});

    final back = tester.getCenter(find.byTooltip('Back'));
    final home = tester.getCenter(find.byTooltip('Home'));
    final screen = tester.getSize(find.byType(Scaffold));

    expect(back.dx, lessThan(screen.width / 4));
    expect(back.dy, lessThan(screen.height / 6));
    expect(home.dx, closeTo(screen.width / 2, 1));
    expect(home.dy, greaterThan(screen.height * 0.8));
    expect(find.text('Body'), findsOneWidget);
  });

  testWidgets('the top-right slot shows what the screen gives it', (
    tester,
  ) async {
    await openScreen(
      tester,
      onBack: () {},
      topRight: const Icon(Icons.star, semanticLabel: 'Stars'),
    );

    final star = tester.getCenter(find.bySemanticsLabel('Stars'));
    expect(
      star.dx,
      greaterThan(tester.getSize(find.byType(Scaffold)).width * 0.75),
    );
  });

  testWidgets('Back calls the screen; Home goes to Who\'s reading', (
    tester,
  ) async {
    var backTaps = 0;
    await openScreen(tester, onBack: () => backTaps++);

    await tester.tap(find.byTooltip('Back'));
    expect(backTaps, 1);

    await tester.tap(find.byTooltip('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Who is reading'), findsOneWidget);
  });
}
