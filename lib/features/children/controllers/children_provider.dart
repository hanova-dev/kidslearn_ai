import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../data/models/child_profile.dart';

/// The signed-in parent's children, loaded from SQLite (oldest first).
final childrenProvider = FutureProvider.autoDispose<List<ChildProfile>>((
  ref,
) async {
  final parentId = ref.read(authRepositoryProvider).currentUserId;
  if (parentId == null) {
    return [];
  }
  return ref.watch(childRepositoryProvider).getChildren(parentId);
});
