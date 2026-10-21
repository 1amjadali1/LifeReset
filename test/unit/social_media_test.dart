import 'package:flutter_test/flutter_test.dart';
import 'package:life_reset/data/local/app_database.dart';
import 'package:life_reset/data/local/preferences_service.dart';
import 'package:life_reset/data/repositories/settings_repository.dart';
import 'package:life_reset/data/repositories/social_media_repository.dart';
import 'package:life_reset/logic/social_media_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Social Media Time Awareness Logic Tests', () {
    late AppDatabase appDb;
    late SocialMediaRepository repository;
    late SettingsRepository settingsRepository;
    late SocialMediaController controller;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'daily_social_media_limit_minutes': 60,
      });
      final prefs = await SharedPreferences.getInstance();

      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
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
          },
        ),
      );
      appDb = AppDatabase(database: db);
      repository = SqliteSocialMediaRepository(appDb);
      settingsRepository = AppSettingsRepository(
        database: appDb,
        preferences: PreferencesService(preferences: prefs),
      );
      controller = SocialMediaController(
        repository: repository,
        settingsRepository: settingsRepository,
      );
      await controller.loadData();
    });

    tearDown(() async {
      await appDb.close();
    });

    test('Add valid entry updates today totals', () async {
      final added = await controller.addEntry(
        appName: 'Instagram',
        durationMinutes: 30,
        notes: 'Casual scroll during lunch',
      );
      expect(added, isTrue);
      expect(controller.todayTotalMinutes, 30);
      expect(controller.todayEntries.length, 1);
      expect(controller.isLimitExceeded, isFalse);
    });

    test('Reject empty app name or non-positive duration', () async {
      final invalidName = await controller.addEntry(
        appName: '  ',
        durationMinutes: 15,
      );
      expect(invalidName, isFalse);
      expect(controller.errorMessage, contains('App name'));

      final invalidDuration = await controller.addEntry(
        appName: 'YouTube',
        durationMinutes: 0,
      );
      expect(invalidDuration, isFalse);
      expect(controller.errorMessage, contains('Duration'));
    });

    test(
      'Limit exceeded flag activates when logged time surpasses limit',
      () async {
        expect(controller.dailyLimitMinutes, 60);

        // Add 45 mins -> within limit
        await controller.addEntry(appName: 'Reddit', durationMinutes: 45);
        expect(controller.isLimitExceeded, isFalse);

        // Add 20 more mins -> total 65 mins -> exceeded!
        await controller.addEntry(appName: 'X (Twitter)', durationMinutes: 20);
        expect(controller.todayTotalMinutes, 65);
        expect(controller.isLimitExceeded, isTrue);
      },
    );

    test('Delete entry deducts duration from daily total', () async {
      await controller.addEntry(appName: 'YouTube', durationMinutes: 40);
      expect(controller.todayTotalMinutes, 40);

      final entryId = controller.todayEntries.first.id;
      await controller.deleteEntry(entryId);

      expect(controller.todayTotalMinutes, 0);
      expect(controller.todayEntries, isEmpty);
    });
  });
}
