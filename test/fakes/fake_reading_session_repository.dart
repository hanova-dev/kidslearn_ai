import 'package:kidslearn_ai/data/models/reading_session.dart';
import 'package:kidslearn_ai/data/reading_session_repository.dart';

/// In-memory [ReadingSessionRepository] for widget tests.
class FakeReadingSessionRepository implements ReadingSessionRepository {
  final List<ReadingSession> saved = [];

  @override
  Future<void> saveSession(ReadingSession session) async {
    saved.add(session);
  }

  @override
  Future<List<ReadingSession>> getSessionsForChild(String childId) async {
    final result = <ReadingSession>[];
    for (final session in saved) {
      if (session.childId == childId) {
        result.add(session);
      }
    }
    return result;
  }
}
