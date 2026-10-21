import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Database helper for Life Reset.
/// Manages SQLite connection, table schemas, and data wipe operations.
class AppDatabase {
  AppDatabase({Database? database, this.factory}) : _db = database;

  static const String _dbName = 'life_reset.db';
  static const int _dbVersion = 1;

  Database? _db;
  final DatabaseFactory? factory;

  /// Returns the active [Database] instance, initializing it if necessary.
  Future<Database> get database async {
    if (_db != null && _db!.isOpen) {
      return _db!;
    }
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final effectiveFactory = factory ?? databaseFactory;
    final databasesPath = await effectiveFactory.getDatabasesPath();
    final path = p.join(databasesPath, _dbName);

    return await effectiveFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _dbVersion,
        onCreate: _onCreate,
        onConfigure: _onConfigure,
      ),
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Goals Table
    await db.execute('''
      CREATE TABLE goals (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        target_date TEXT,
        is_completed INTEGER NOT NULL DEFAULT 0,
        is_daily_priority INTEGER NOT NULL DEFAULT 0,
        completed_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 2. Habits Table
    await db.execute('''
      CREATE TABLE habits (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        icon_code_point INTEGER,
        color_hex TEXT,
        is_archived INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // 3. Habit Completions Table (Enforces single completion per habit per calendar day)
    await db.execute('''
      CREATE TABLE habit_completions (
        id TEXT PRIMARY KEY,
        habit_id TEXT NOT NULL,
        date_string TEXT NOT NULL,
        completed_at TEXT NOT NULL,
        UNIQUE(habit_id, date_string) ON CONFLICT REPLACE,
        FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE
      )
    ''');

    // 4. Focus Sessions Table
    await db.execute('''
      CREATE TABLE focus_sessions (
        id TEXT PRIMARY KEY,
        duration_minutes INTEGER NOT NULL,
        actual_elapsed_seconds INTEGER NOT NULL,
        goal_id TEXT,
        label TEXT,
        started_at TEXT NOT NULL,
        completed_at TEXT NOT NULL
      )
    ''');

    // 5. Social Media Usage Table
    await db.execute('''
      CREATE TABLE social_media_entries (
        id TEXT PRIMARY KEY,
        app_name TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL,
        date_string TEXT NOT NULL,
        logged_at TEXT NOT NULL,
        notes TEXT
      )
    ''');
  }

  /// Safely deletes all records across all tables.
  Future<void> deleteAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('habit_completions');
      await txn.delete('habits');
      await txn.delete('goals');
      await txn.delete('focus_sessions');
      await txn.delete('social_media_entries');
    });
  }

  /// Closes the database connection.
  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }
}
