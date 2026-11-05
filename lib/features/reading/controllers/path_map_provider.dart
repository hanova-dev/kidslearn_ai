import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../children/controllers/active_child.dart';
import 'path_node.dart';

/// The active child's path: approved stories as circles, oldest first (design p15, decision 024).
final pathMapProvider = FutureProvider.autoDispose<List<PathNode>>((ref) async {
  final child = ref.watch(activeChildProvider);
  if (child == null) {
    return [];
  }

  // ── Approved stories of this child ──
  final stories = await ref
      .watch(storyRepositoryProvider)
      .getApprovedStoriesForChild(child.id);

  // ── Stories this child has finished reading ──
  final sessions = await ref
      .watch(readingSessionRepositoryProvider)
      .getSessionsForChild(child.id);
  final finishedIds = <String>{};
  for (final session in sessions) {
    finishedIds.add(session.storyId);
  }

  return buildPathNodes(stories, finishedIds);
});
