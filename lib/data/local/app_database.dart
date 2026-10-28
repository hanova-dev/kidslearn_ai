import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Opens the app's single SQLite database and creates its tables.
class AppDatabase {
  static const String fileName = 'kidslearn.db';
  static const int version = 1;

  /// Opens (or creates) kidslearn.db in the app's private documents folder.
  static Future<Database> open() async {
    final folder = await getApplicationDocumentsDirectory();
    return openDatabase(
      '${folder.path}/$fileName',
      version: version,
      onCreate: createTables,
    );
  }

  /// Runs once, when the database file is first created.
  static Future<void> createTables(Database db, int version) async {
    // ── child_profiles ──
    await db.execute('''
      CREATE TABLE child_profiles (
        child_id TEXT PRIMARY KEY,
        parent_id TEXT NOT NULL,
        name TEXT NOT NULL,
        buddy TEXT NOT NULL,
        age_group TEXT NOT NULL,
        language TEXT NOT NULL,
        star_balance INTEGER NOT NULL DEFAULT 0,
        reading_level INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL
      )
    ''');
  }
}
