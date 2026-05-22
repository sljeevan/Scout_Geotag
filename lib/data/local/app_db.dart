import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class AppDb {
  static Database? _db;
  static DatabaseFactory get _factory =>
      kIsWeb ? databaseFactoryFfiWebNoWebWorker : databaseFactory;

  static Future<Database> get instance async {
    if (_db != null) return _db!;
    final dbPath = kIsWeb ? null : await getDatabasesPath();
    final dbName = 'sitepin_flutter.db';
    _db = await _factory.openDatabase(
      dbPath == null ? dbName : join(dbPath, dbName),
      options: OpenDatabaseOptions(
      version: 4,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE,
            org_id TEXT,
            role TEXT,
            is_active INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE projects (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            remote_id TEXT,
            user_id INTEGER,
            project_name TEXT,
            developer TEXT,
            architect TEXT,
            pmc TEXT,
            facade_consultant TEXT,
            segment TEXT,
            status TEXT,
            outcome TEXT,
            remarks TEXT,
            latitude REAL,
            longitude REAL,
            photo_path TEXT,
            created_at INTEGER,
            updated_at INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE sync_queue (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            idempotency_key TEXT UNIQUE,
            operation TEXT,
            entity_id TEXT,
            payload_json TEXT,
            status TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE visits (
            id TEXT PRIMARY KEY,
            project_id TEXT NOT NULL,
            user_id INTEGER NOT NULL,
            visit_type TEXT NOT NULL,
            visit_date INTEGER NOT NULL,
            start_time TEXT,
            end_time TEXT,
            client_name TEXT,
            partner_name TEXT,
            attendees TEXT,
            discussion_points TEXT,
            decisions_taken TEXT,
            action_items TEXT,
            outcome_status TEXT,
            latitude REAL,
            longitude REAL,
            sync_status TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE projects ADD COLUMN remarks TEXT');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE projects ADD COLUMN developer TEXT');
          await db.execute('ALTER TABLE projects ADD COLUMN architect TEXT');
          await db.execute('ALTER TABLE projects ADD COLUMN pmc TEXT');
          await db.execute(
              'ALTER TABLE projects ADD COLUMN facade_consultant TEXT');
        }
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS visits (
              id TEXT PRIMARY KEY,
              project_id TEXT NOT NULL,
              user_id INTEGER NOT NULL,
              visit_type TEXT NOT NULL,
              visit_date INTEGER NOT NULL,
              start_time TEXT,
              end_time TEXT,
              client_name TEXT,
              partner_name TEXT,
              attendees TEXT,
              discussion_points TEXT,
              decisions_taken TEXT,
              action_items TEXT,
              outcome_status TEXT,
              latitude REAL,
              longitude REAL,
              sync_status TEXT NOT NULL,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL
            )
          ''');
        }
      },),
    );
    return _db!;
  }
}
