import 'package:flutter_riverpod/flutter_riverpod.dart';

/// True while the parent area is open; app start and child mode lock it (SRS D7).
class ParentUnlock extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  /// Opens the parent area (after log in or a correct gate answer).
  void unlock() {
    state = true;
  }

  /// Closes the parent area (going to child mode or logging out).
  void lock() {
    state = false;
  }
}

/// Lets the router and screens read or change [ParentUnlock].
final parentUnlockProvider = NotifierProvider<ParentUnlock, bool>(
  ParentUnlock.new,
);
