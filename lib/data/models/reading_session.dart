/// One finished reading of one story by one child (SRS 6.2 reading_sessions, decision 024).
class ReadingSession {
  const ReadingSession({
    required this.id,
    required this.childId,
    required this.storyId,
    required this.mode,
    required this.wordsRead,
    required this.starsEarned,
    required this.lastModified,
  });

  final String id;
  final String childId;
  final String storyId;

  /// 'LISTENER' or 'READER' (SRS 10.4).
  final String mode;
  final int wordsRead;
  final int starsEarned;
  final DateTime lastModified;

  // ── To SQLite row ──
  /// Converts this session to a map; the sync columns keep their table defaults.
  Map<String, Object> toMap() {
    return {
      'session_id': id,
      'child_id': childId,
      'story_id': storyId,
      'mode': mode,
      'words_read': wordsRead,
      'stars_earned': starsEarned,
      'last_modified': lastModified.millisecondsSinceEpoch,
    };
  }

  // ── From SQLite row ──
  /// Builds a session from one SQLite row.
  factory ReadingSession.fromMap(Map<String, Object?> map) {
    return ReadingSession(
      id: map['session_id'] as String,
      childId: map['child_id'] as String,
      storyId: map['story_id'] as String,
      mode: map['mode'] as String,
      wordsRead: map['words_read'] as int,
      starsEarned: map['stars_earned'] as int,
      lastModified: DateTime.fromMillisecondsSinceEpoch(
        map['last_modified'] as int,
      ),
    );
  }
}
