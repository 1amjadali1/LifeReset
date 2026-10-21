import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:life_reset/data/local/app_database.dart';
import 'package:life_reset/data/local/preferences_service.dart';
import 'package:life_reset/data/repositories/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Settings and Data Export/Wipe Tests', () {
    late AppDatabase appDb;
    late PreferencesService preferences;
    late SettingsRepository settingsRepo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      preferences = PreferencesService(preferences: prefs);

      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
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
              );
            ''');
            await db.execute('''
              CREATE TABLE habits (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                icon_code_point INTEGER NOT NULL DEFAULT 57867,
                created_at TEXT NOT NULL,
                is_archived INTEGER NOT NULL DEFAULT 0
              );
            ''');
            await db.execute('''
              CREATE TABLE habit_completions (
                id TEXT PRIMARY KEY,
                habit_id TEXT NOT NULL,
                completion_date TEXT NOT NULL,
                created_at TEXT NOT NULL,
                UNIQUE(habit_id, completion_date)
              );
            ''');
            await db.execute('''
              CREATE TABLE focus_sessions (
                id TEXT PRIMARY KEY,
                duration_minutes INTEGER NOT NULL,
                actual_elapsed_seconds INTEGER NOT NULL,
                goal_id TEXT,
                label TEXT,
                started_at TEXT NOT NULL,
                completed_at TEXT NOT NULL
              );
            ''');
            await db.execute('''
              CREATE TABLE social_media_entries (
                id TEXT PRIMARY KEY,
                app_name TEXT NOT NULL,
                duration_minutes INTEGER NOT NULL,
                entry_date TEXT NOT NULL,
                notes TEXT,
                created_at TEXT NOT NULL
              );
            ''');
          },
        ),
      );
      appDb = AppDatabase(database: db);
      settingsRepo = AppSettingsRepository(
        database: appDb,
        preferences: preferences,
      );
    });

    tearDown(() async {
      await appDb.close();
    });

    test('Preferences return clean defaults and support mutation', () async {
      expect(await settingsRepo.getDailySocialMediaLimit(), 60);
      expect(await settingsRepo.getDefaultFocusDuration(), 25);

      await settingsRepo.setDailySocialMediaLimit(45);
      await settingsRepo.setDefaultFocusDuration(30);

      expect(await settingsRepo.getDailySocialMediaLimit(), 45);
      expect(await settingsRepo.getDefaultFocusDuration(), 30);
    });

    test(
      'JSON Export contains metadata, preferences, and all data tables',
      () async {
        await settingsRepo.setDailySocialMediaLimit(90);
        await settingsRepo.setDefaultFocusDuration(50);

        final db = await appDb.database;
        await db.insert('goals', {
          'id': 'g1',
          'title': 'Test Goal',
          'is_completed': 0,
          'is_daily_priority': 1,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        final jsonString = await settingsRepo.exportDataAsJson();
        final map = jsonDecode(jsonString) as Map<String, dynamic>;

        expect(map['app'], 'Life Reset');
        expect(map['version'], '1.0.0');
        expect(map.containsKey('exported_at'), isTrue);

        final prefs = map['preferences'] as Map<String, dynamic>;
        expect(prefs['daily_social_media_limit_minutes'], 90);
        expect(prefs['default_focus_duration_minutes'], 50);

        final goals = map['goals'] as List<dynamic>;
        expect(goals.length, 1);
        expect(goals[0]['title'], 'Test Goal');

        expect(map.containsKey('habits'), isTrue);
        expect(map.containsKey('habit_completions'), isTrue);
        expect(map.containsKey('focus_sessions'), isTrue);
        expect(map.containsKey('social_media_entries'), isTrue);
      },
    );

    test(
      'Data wipe completely erases database records and preferences',
      () async {
        await settingsRepo.setDailySocialMediaLimit(75);
        final db = await appDb.database;
        await db.insert('goals', {
          'id': 'g2',
          'title': 'To be deleted',
          'is_completed': 0,
          'is_daily_priority': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        await settingsRepo.deleteAllAppData();

        final goalsCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM goals'),
        );
        expect(goalsCount, 0);

        // Preferences should revert to defaults after wipe
        expect(await settingsRepo.getDailySocialMediaLimit(), 60);
        expect(await settingsRepo.getDefaultFocusDuration(), 25);
      },
    );
  });
}
