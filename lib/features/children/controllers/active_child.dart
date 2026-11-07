import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/child_profile.dart';

/// The child who is reading now on this shared phone (FR-AUTH-05).
class ActiveChild extends Notifier<ChildProfile?> {
  @override
  ChildProfile? build() {
    return null;
  }

  /// Makes [child] the active reader.
  void select(ChildProfile child) {
    state = child;
  }

  /// Shows [stars] more on the active child, after they were saved (FR-MODE-06).
  void addStars(int stars) {
    final child = state;
    if (child == null) {
      return;
    }
    state = ChildProfile(
      id: child.id,
      parentId: child.parentId,
      name: child.name,
      buddyId: child.buddyId,
      ageGroup: child.ageGroup,
      language: child.language,
      starBalance: child.starBalance + stars,
      readingLevel: child.readingLevel,
      createdAt: child.createdAt,
    );
  }
}

/// Lets child screens read or change the [ActiveChild].
final activeChildProvider = NotifierProvider<ActiveChild, ChildProfile?>(
  ActiveChild.new,
);
