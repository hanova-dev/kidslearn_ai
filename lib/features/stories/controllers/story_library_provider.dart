import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import 'library_item.dart';
import 'story_creation.dart';
import 'story_creation_controller.dart';

/// Every story of the signed-in parent, newest first, with a cover picture (design p9).
///
/// It watches the story creation, so a card changes while its story is written and drawn.
final storyLibraryProvider = FutureProvider.autoDispose<List<LibraryItem>>((
  ref,
) async {
  final creation = ref.watch(storyCreationControllerProvider);
  final parentId = ref.read(authRepositoryProvider).currentUserId ?? '';
  final stories = ref.read(storyRepositoryProvider);

  // ── Child names by child id ──
  final children = await ref
      .read(childRepositoryProvider)
      .getChildren(parentId);
  final names = <String, String>{};
  for (final child in children) {
    names[child.id] = child.name;
  }

  // ── One card per story; the cover is the first drawn scene ──
  final items = <LibraryItem>[];
  for (final story in await stories.getStoriesForParent(parentId)) {
    String? coverPath;
    for (final scene in await stories.getScenes(story.id)) {
      if (scene.imagePath != null) {
        coverPath = scene.imagePath;
        break;
      }
    }
    final isWriting =
        creation.step == CreationStep.writing && creation.story?.id == story.id;
    items.add(
      LibraryItem(
        story: story,
        childName: names[story.childId] ?? '',
        coverPath: coverPath,
        isWriting: isWriting,
      ),
    );
  }
  return items;
});
