import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/constants/buddies.dart';
import '../../../data/models/age_group.dart';
import '../../../data/models/child_profile.dart';
import 'children_provider.dart';

/// Saves a new child profile and remembers loading or error (FR-AUTH-02).
class AddChildController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Saves the child for the signed-in parent; returns true on success.
  Future<bool> save({
    required String name,
    required Buddy buddy,
    required AgeGroup ageGroup,
  }) async {
    // ── Build the profile ──
    final parentId = ref.read(authRepositoryProvider).currentUserId;
    if (parentId == null) {
      state = AsyncError(StateError('Not signed in'), StackTrace.current);
      return false;
    }
    final now = DateTime.now();
    final child = ChildProfile(
      id: 'child-${now.microsecondsSinceEpoch}',
      parentId: parentId,
      name: name.trim(),
      buddyId: buddy.id,
      ageGroup: ageGroup,
      language: 'en',
      starBalance: 0,
      readingLevel: 1,
      createdAt: now,
    );

    // ── Save to SQLite ──
    final repository = ref.read(childRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => repository.addChild(child));
    if (state.hasError) {
      return false;
    }

    // ── Refresh the children list ──
    ref.invalidate(childrenProvider);
    return true;
  }
}

/// Gives the Add child screen access to its [AddChildController].
final addChildControllerProvider =
    AsyncNotifierProvider<AddChildController, void>(AddChildController.new);
