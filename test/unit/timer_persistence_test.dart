import 'package:flutter_test/flutter_test.dart';
import 'package:life_reset/data/local/app_database.dart';
import 'package:life_reset/data/local/preferences_service.dart';
import 'package:life_reset/data/repositories/focus_repository.dart';
import 'package:life_reset/logic/focus_timer_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Focus Timer Persistence and Restoration Tests', () {
    late AppDatabase appDb;
    late PreferencesService preferences;
    late FocusRepository repository;

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
          },
        ),
      );
      appDb = AppDatabase(database: db);
      repository = SqliteFocusRepository(appDb);
    });

    tearDown(() async {
      await appDb.close();
    });

    test(
      'Starting and pausing timer persists active state to preferences',
      () async {
        final controller = FocusTimerController(repository, preferences);
        controller.setDurationMinutes(30);
        controller.setSessionLabel('Deep Work');
        await controller.startTimer();

        var state = await preferences.getActiveTimerState();
        expect(state, isNotNull);
        expect(state!['status'], 'running');
        expect(state['targetMinutes'], 30);
        expect(state['sessionLabel'], 'Deep Work');

        await controller.pauseTimer();
        state = await preferences.getActiveTimerState();
        expect(state!['status'], 'paused');

        await controller.cancelTimer();
        state = await preferences.getActiveTimerState();
        expect(state, isNull);
      },
    );

    test(
      'Fresh controller instance restores paused timer state cleanly',
      () async {
        // Setup state in preferences as if previously paused
        await preferences.saveActiveTimerState(
          status: 'paused',
          targetMinutes: 20,
          accumulatedSeconds: 300,
          linkedGoalId: 'goal-42',
          sessionLabel: 'Revision',
        );

        final newController = FocusTimerController(repository, preferences);
        expect(newController.status, FocusTimerStatus.idle);

        await newController.restoreTimerState();

        expect(newController.status, FocusTimerStatus.paused);
        expect(newController.targetDurationMinutes, 20);
        expect(newController.elapsedSeconds, 300);
        expect(newController.remainingSeconds, 900);
        expect(newController.linkedGoalId, 'goal-42');
        expect(newController.sessionLabel, 'Revision');

        newController.cancelTimer();
      },
    );

    test(
      'Restores and completes timer if elapsed wall-clock time passed target',
      () async {
        // Simulate session that started 30 mins ago for 25 min target
        final pastStart = DateTime.now().subtract(const Duration(minutes: 30));
        await preferences.saveActiveTimerState(
          status: 'running',
          targetMinutes: 25,
          accumulatedSeconds: 0,
          segmentStartMs: pastStart.millisecondsSinceEpoch,
          sessionStartMs: pastStart.millisecondsSinceEpoch,
          sessionLabel: 'Background Finished Task',
        );

        final controller = FocusTimerController(repository, preferences);
        await controller.restoreTimerState();

        // Controller should transition to completed and record session
        expect(controller.status, FocusTimerStatus.completed);
        final sessions = await repository.getAllSessions();
        expect(sessions.length, 1);
        expect(sessions.first.label, 'Background Finished Task');
        expect(sessions.first.durationMinutes, 25);

        // Preferences should now be cleared
        final state = await preferences.getActiveTimerState();
        expect(state, isNull);
      },
    );
  });
}
