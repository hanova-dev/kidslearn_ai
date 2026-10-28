import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_auth_repository.dart';
import '../helpers/test_app.dart';

void main() {
  Future<FakeAuthRepository> openLogin(WidgetTester tester) async {
    final repository = FakeAuthRepository();
    usePhoneScreen(tester);
    await tester.pumpWidget(buildTestApp(auth: repository));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    return repository;
  }

  Future<void> fillForm(
    WidgetTester tester,
    String email,
    String password,
  ) async {
    await tester.enterText(find.byType(TextFormField).at(0), email);
    await tester.enterText(find.byType(TextFormField).at(1), password);
  }

  // ── Field checks ──
  testWidgets('empty form shows friendly field messages', (tester) async {
    await openLogin(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pump();

    expect(find.text('Please type your email.'), findsOneWidget);
    expect(find.text('Password needs at least 6 characters.'), findsOneWidget);
  });

  // ── Wrong password ──
  testWidgets('wrong password shows a plain message and stays', (tester) async {
    await openLogin(tester);
    await fillForm(tester, FakeAuthRepository.knownEmail, 'wrong-pass');

    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pumpAndSettle();

    expect(
      find.text('Email or password is not right. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Welcome, grown-up!'), findsOneWidget);
  });

  // ── Correct log in ──
  testWidgets('correct email and password open parent home', (tester) async {
    await openLogin(tester);
    await fillForm(
      tester,
      FakeAuthRepository.knownEmail,
      FakeAuthRepository.knownPassword,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Your readers'), findsOneWidget);
  });

  // ── Sign up ──
  testWidgets('sign up with a new email opens Add child', (tester) async {
    await openLogin(tester);
    await tester.tap(find.text('Sign up'));
    await tester.pump();
    await fillForm(tester, 'new.parent@email.com', 'secret123');

    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Who is our new reader?'), findsOneWidget);
  });

  // ── Forgot password ──
  testWidgets('forgot password sends a reset email', (tester) async {
    final repository = await openLogin(tester);
    await tester.enterText(
      find.byType(TextFormField).at(0),
      FakeAuthRepository.knownEmail,
    );

    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();

    expect(repository.resetEmailsSent, [FakeAuthRepository.knownEmail]);
    expect(
      find.text('We sent a reset link to ${FakeAuthRepository.knownEmail}.'),
      findsOneWidget,
    );
  });
}
