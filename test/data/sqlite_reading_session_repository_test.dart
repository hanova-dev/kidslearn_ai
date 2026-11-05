import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/data/local/app_database.dart';
import 'package:kidslearn_ai/data/local/sqlite_reading_session_repository.dart';
import 'package:kidslearn_ai/data/models/reading_session.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

ReadingSession makeSession(String id, String childId, int day) {
  return ReadingSession(
    id: id,
    childId: childId,
    storyId: 'story-$id',
    mode: 'READER',
    wordsRead: 18,
    starsEarned: 15,
    lastModified: DateTime(2026, 11, day),
  );
}

void main() {
  late Database db;
  late SqliteReadingSessionRepository repository;

  // ── Fresh in-memory database (newest version) for every test ──
  setUpAll(sqfliteFfiInit);
  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: AppDatabase.version,
        onCreate: AppDatabase.createTables,
      ),
    );
    repository = SqliteReadingSessionRepository(db);
  });
  tearDown(() => db.close());

  // ── Save and load (decision 024) ──
  test('a session is saved and read back with all its fields', () async {
    await repository.saveSession(makeSession('r1', 'child-1', 4));

    final sessions = await repository.getSessionsForChild('child-1');

    expect(sessions.length, 1);
    expect(sessions.first.storyId, 'story-r1');
    expect(sessions.first.mode, 'READER');
    expect(sessions.first.wordsRead, 18);
    expect(sessions.first.starsEarned, 15);
    expect(sessions.first.lastModified, DateTime(2026, 11, 4));
  });

  test('only one child gets their sessions back, oldest first', () async {
    await repository.saveSession(makeSession('late', 'child-1', 5));
    await repository.saveSession(makeSession('early', 'child-1', 2));
    await repository.saveSession(makeSession('other', 'child-2', 3));

    final sessions = await repository.getSessionsForChild('child-1');

    expect(sessions.map((session) => session.id).toList(), ['early', 'late']);
  });
}
