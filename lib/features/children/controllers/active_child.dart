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
}

/// Lets child screens read or change the [ActiveChild].
final activeChildProvider = NotifierProvider<ActiveChild, ChildProfile?>(
  ActiveChild.new,
);
