import '../../../data/models/story.dart';
import '../../../data/models/story_status.dart';

/// The small label on a library card (decision 023).
enum LibraryBadge { writing, drawing, needsCheck, approved, stopped }

/// One card in the Story library: the story, its child's name and its cover picture.
class LibraryItem {
  const LibraryItem({
    required this.story,
    required this.childName,
    required this.coverPath,
    required this.isWriting,
  });

  final Story story;
  final String childName;

  /// The first drawn scene's picture file, or null when nothing is drawn yet.
  final String? coverPath;

  /// True while the story model is still writing this story's text.
  final bool isWriting;

  /// Which badge the card shows, from the status and the approval.
  LibraryBadge get badge {
    switch (story.status) {
      case StoryStatus.draft:
        return LibraryBadge.writing;
      case StoryStatus.generating:
        return isWriting ? LibraryBadge.writing : LibraryBadge.drawing;
      case StoryStatus.ready:
        return story.approved ? LibraryBadge.approved : LibraryBadge.needsCheck;
      case StoryStatus.failed:
        return LibraryBadge.stopped;
    }
  }

  /// True while the story is still being made (it opens the Story generating screen).
  bool get isInProgress {
    return story.status == StoryStatus.draft ||
        story.status == StoryStatus.generating;
  }
}
