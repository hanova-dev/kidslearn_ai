import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Opens the app's single SQLite database and creates or upgrades its tables.
class AppDatabase {
  static const String fileName = 'kidslearn.db';

  /// 1 = child_profiles; 2 = + stories and scenes; 3 = + reading_sessions; 4 = + scenes.motion_json.
  static const int version = 4;

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
    await createReadingSessionsTable(db);
    await addSceneMotionColumn(db);
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
    if (oldVersion < 3) {
      await createReadingSessionsTable(db);
    }
    if (oldVersion < 4) {
      await addSceneMotionColumn(db);
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

  // ── Version 3: reading_sessions (decision 024) ──
  static Future<void> createReadingSessionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE reading_sessions (
        session_id TEXT PRIMARY KEY,
        child_id TEXT NOT NULL,
        story_id TEXT NOT NULL,
        mode TEXT NOT NULL,
        words_read INTEGER NOT NULL DEFAULT 0,
        stars_earned INTEGER NOT NULL DEFAULT 0,
        local_version INTEGER NOT NULL DEFAULT 1,
        device_id TEXT NOT NULL DEFAULT '',
        sync_state TEXT NOT NULL DEFAULT 'PENDING',
        last_modified INTEGER NOT NULL
      )
    ''');
  }

  // ── Version 4: motion directives on scenes (M11, decision 033) ──
  /// Old rows get NULL, which the app reads as the calm motion.
  static Future<void> addSceneMotionColumn(Database db) async {
    await db.execute('ALTER TABLE scenes ADD COLUMN motion_json TEXT');
  }
}
