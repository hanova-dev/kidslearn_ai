import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Opens the app's single SQLite database and creates or upgrades its tables.
class AppDatabase {
  static const String fileName = 'kidslearn.db';

  /// 1 = child_profiles; 2 = + stories and scenes.
  static const int version = 2;

  /// Opens (or creates) kidslearn.db in the app's private documents folder.
  static Future<Database> open() async {
    final folder = await getApplicationDocumentsDirectory();
    return openDatabase(
      '${folder.path}/$fileName',
      version: version,
      onCreate: createTables,
      onUpgrade: upgradeTables,
    );
  }

  /// Runs once on a new phone: creates every table of the newest version.
  static Future<void> createTables(Database db, int version) async {
    await createChildProfilesTable(db);
    await createStoryTables(db);
  }

  /// Runs on a phone that has an older database file; keeps existing rows.
  static Future<void> upgradeTables(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await createStoryTables(db);
    }
  }

  // ── Version 1: child_profiles ──
  static Future<void> createChildProfilesTable(Database db) async {
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

  // ── Version 2: stories and scenes ──
  static Future<void> createStoryTables(Database db) async {
    await db.execute('''
      CREATE TABLE stories (
        story_id TEXT PRIMARY KEY,
        parent_id TEXT NOT NULL,
        child_id TEXT NOT NULL,
        prompt_text TEXT NOT NULL,
        prompt_value TEXT NOT NULL,
        title TEXT NOT NULL,
        moral_value TEXT NOT NULL,
        language TEXT NOT NULL,
        character_sheet TEXT NOT NULL,
        seed INTEGER NOT NULL,
        status TEXT NOT NULL,
        approved INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE scenes (
        scene_id TEXT PRIMARY KEY,
        story_id TEXT NOT NULL,
        sequence_number INTEGER NOT NULL,
        text TEXT NOT NULL,
        image_prompt TEXT NOT NULL,
        image_path TEXT,
        image_source TEXT
      )
    ''');
  }
}
