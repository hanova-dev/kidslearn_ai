import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import 'parent_unlock.dart';

/// Runs log in, sign up and password reset, and remembers loading or error.
class LoginController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Signs in an existing parent. On failure the state holds an AuthFailure.
  Future<void> logIn(String email, String password) async {
    final repository = ref.read(authRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return repository.logIn(email: email.trim(), password: password);
    });
    _unlockParentAreaIfSignedIn();
  }

  /// Creates a new parent account and signs it in.
  Future<void> signUp(String email, String password) async {
    final repository = ref.read(authRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return repository.signUp(email: email.trim(), password: password);
    });
    _unlockParentAreaIfSignedIn();
  }

  /// Sends a reset link; returns true when the email was sent.
  Future<bool> sendPasswordReset(String email) async {
    final repository = ref.read(authRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return repository.sendPasswordReset(email.trim());
    });
    return !state.hasError;
  }

  // ── A parent who just typed their password may open the parent area ──
  void _unlockParentAreaIfSignedIn() {
    if (!state.hasError) {
      ref.read(parentUnlockProvider.notifier).unlock();
    }
  }
}

/// Gives the login screen access to its [LoginController].
final loginControllerProvider = AsyncNotifierProvider<LoginController, void>(
  LoginController.new,
);
