import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/data/local/app_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  // ── A phone with the version-1 database keeps its children ──
  test(
    'upgrading from version 1 adds story tables and keeps children',
    () async {
      final folder = Directory.systemTemp.createTempSync('kidslearn_db_');
      final path = '${folder.path}/kidslearn.db';
      addTearDown(() => folder.deleteSync(recursive: true));

      // Version 1, as it was on the phone before this task.
      var db = await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) => AppDatabase.createChildProfilesTable(db),
        ),
      );
      await db.insert('child_profiles', {
        'child_id': 'c1',
        'parent_id': 'p1',
        'name': 'Zayan',
        'buddy': 'leafy',
        'age_group': 'listener_2_4',
        'language': 'en',
        'created_at': 0,
      });
      await db.close();

      // Open again with the app's current version and upgrade step.
      db = await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: AppDatabase.version,
          onCreate: AppDatabase.createTables,
          onUpgrade: AppDatabase.upgradeTables,
        ),
      );
      final tables = await db.query(
        'sqlite_master',
        columns: ['name'],
        where: "type = 'table'",
      );
      final tableNames = tables.map((row) => row['name']).toList();
      final children = await db.query('child_profiles');
      await db.close();

      expect(tableNames, containsAll(['child_profiles', 'stories', 'scenes']));
      expect(children.length, 1);
      expect(children.first['name'], 'Zayan');
    },
  );
}
