import 'package:flutter_test/flutter_test.dart';
import 'package:life_reset/core/utils/date_utils.dart';
import 'package:life_reset/data/local/app_database.dart';
import 'package:life_reset/data/models/focus_session.dart';
import 'package:life_reset/data/models/goal.dart';
import 'package:life_reset/data/models/habit.dart';
import 'package:life_reset/data/models/social_media_entry.dart';
import 'package:life_reset/data/repositories/focus_repository.dart';
import 'package:life_reset/data/repositories/goal_repository.dart';
import 'package:life_reset/data/repositories/habit_repository.dart';
import 'package:life_reset/data/repositories/social_media_repository.dart';
import 'package:life_reset/logic/progress_controller.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Progress and Weekly Aggregation Tests', () {
    late AppDatabase appDb;
    late FocusRepository focusRepository;
    late SocialMediaRepository socialMediaRepository;
    late HabitRepository habitRepository;
    late GoalRepository goalRepository;
    late ProgressController controller;

    setUp(() async {
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
              )
            ''');
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
      focusRepository = SqliteFocusRepository(appDb);
      socialMediaRepository = SqliteSocialMediaRepository(appDb);
      habitRepository = SqliteHabitRepository(appDb);
      goalRepository = SqliteGoalRepository(appDb);

      controller = ProgressController(
        focusRepository: focusRepository,
        socialMediaRepository: socialMediaRepository,
        habitRepository: habitRepository,
        goalRepository: goalRepository,
      );
    });

    tearDown(() async {
      await appDb.close();
    });

    test('Empty dataset reports hasAnyData as false and zero counts', () async {
      await controller.loadWeeklyReport();
      final report = controller.report;

      expect(report, isNotNull);
      expect(report!.hasAnyData, isFalse);
      expect(report.totalFocusMinutes, 0);
      expect(report.totalSocialMediaMinutes, 0);
      expect(report.totalHabitCompletions, 0);
      expect(report.totalGoalsCompleted, 0);
      expect(report.dailyMetrics.length, 7);
    });

    test(
      'Aggregates real focus, social media, habit, and goal data accurately',
      () async {
        final now = DateTime.now();
        final todayStr = AppDateUtils.toDateString(now);

        // 1. Add 50 mins focus session
        await focusRepository.saveSession(
          FocusSession(
            durationMinutes: 50,
            actualElapsedSeconds: 3000,
            startedAt: now.subtract(const Duration(minutes: 50)),
            completedAt: now,
          ),
        );

        // 2. Add 20 mins social media entry
        await socialMediaRepository.addEntry(
          SocialMediaEntry(
            appName: 'YouTube',
            durationMinutes: 20,
            dateString: todayStr,
          ),
        );

        // 3. Add habit and complete today
        final habit = Habit(name: 'Morning Routine');
        await habitRepository.createHabit(habit);
        await habitRepository.toggleHabitCompletion(habit.id, todayStr);

        // 4. Add completed goal
        await goalRepository.createGoal(
          Goal(title: 'Milestone Goal', isCompleted: true),
        );

        // Load report
        await controller.loadWeeklyReport();
        final report = controller.report;

        expect(report!.hasAnyData, isTrue);
        expect(report.totalFocusMinutes, 50);
        expect(report.totalSocialMediaMinutes, 20);
        expect(report.totalHabitCompletions, 1);
        expect(report.totalGoalsCompleted, 1);
      },
    );
  });
}
