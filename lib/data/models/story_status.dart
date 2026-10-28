/// Story lifecycle (FR-STORY-04): DRAFT → GENERATING → READY or FAILED.
enum StoryStatus {
  draft('DRAFT'),
  generating('GENERATING'),
  ready('READY'),
  failed('FAILED');

  const StoryStatus(this.dbValue);

  /// Text saved in SQLite (stories.status).
  final String dbValue;

  /// True when the lifecycle allows moving from this status to [next].
  bool canMoveTo(StoryStatus next) {
    switch (this) {
      case StoryStatus.draft:
        return next == StoryStatus.generating || next == StoryStatus.failed;
      case StoryStatus.generating:
        return next == StoryStatus.ready || next == StoryStatus.failed;
      case StoryStatus.ready:
        return next == StoryStatus.generating;
      case StoryStatus.failed:
        return next == StoryStatus.generating;
    }
  }

  /// Turns the saved SQLite text back into a [StoryStatus].
  static StoryStatus fromDbValue(String value) {
    for (final status in StoryStatus.values) {
      if (status.dbValue == value) {
        return status;
      }
    }
    return StoryStatus.failed;
  }
}
