import 'package:sqflite/sqflite.dart';

import '../models/reading_session.dart';
import '../reading_session_repository.dart';

/// [ReadingSessionRepository] that keeps finished readings in local SQLite.
class SqliteReadingSessionRepository implements ReadingSessionRepository {
  SqliteReadingSessionRepository(this._db);

  final Database _db;

  // ── Save ──
  @override
  Future<void> saveSession(ReadingSession session) async {
    await _db.insert('reading_sessions', session.toMap());
  }

  // ── Load ──
  @override
  Future<List<ReadingSession>> getSessionsForChild(String childId) async {
    final rows = await _db.query(
      'reading_sessions',
      where: 'child_id = ?',
      whereArgs: [childId],
      orderBy: 'last_modified ASC',
    );
    final sessions = <ReadingSession>[];
    for (final row in rows) {
      sessions.add(ReadingSession.fromMap(row));
    }
    return sessions;
  }
}
