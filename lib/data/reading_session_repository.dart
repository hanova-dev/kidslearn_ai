import 'models/reading_session.dart';

/// Saves and loads finished readings; screens only know this interface.
abstract class ReadingSessionRepository {
  /// Saves one finished reading of a story (written by Story complete later).
  Future<void> saveSession(ReadingSession session);

  /// Every finished reading of one child, oldest first.
  Future<List<ReadingSession>> getSessionsForChild(String childId);
}
