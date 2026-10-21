import 'package:flutter_test/flutter_test.dart';
import 'package:life_reset/data/local/app_database.dart';
import 'package:life_reset/data/models/habit.dart';
import 'package:life_reset/data/repositories/habit_repository.dart';
import 'package:life_reset/logic/habits_controller.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Habit Repository and Streak Logic Tests', () {
    late AppDatabase appDb;
    late HabitRepository repository;
    late HabitsController controller;

    setUp(() async {
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
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
          },
        ),
      );
      appDb = AppDatabase(database: db);
      repository = SqliteHabitRepository(appDb);
      controller = HabitsController(repository);
      await controller.loadHabits();
    });

    tearDown(() async {
      await appDb.close();
    });

    test('Create and retrieve habit', () async {
      final created = await controller.createHabit(
        name: 'Drink 2L Water',
        description: 'Stay hydrated throughout the day',
      );
      expect(created, isTrue);
      expect(controller.habits.length, 1);
      expect(controller.habits.first.name, 'Drink 2L Water');
    });

    test('Reject empty habit name', () async {
      final created = await controller.createHabit(name: '   ');
      expect(created, isFalse);
      expect(controller.errorMessage, isNotNull);
      expect(controller.habits, isEmpty);
    });

    test('Toggle completion marks habit done and undoes properly', () async {
      await controller.createHabit(name: 'Morning Meditation');
      final habitId = controller.habits.first.id;

      // Mark done today
      await controller.toggleCompletion(habitId);
      expect(controller.completedTodayIds.contains(habitId), isTrue);

      // Undo completion
      await controller.toggleCompletion(habitId);
      expect(controller.completedTodayIds.contains(habitId), isFalse);
    });

    test('Prevent duplicate completions for the same date', () async {
      final habit = Habit(name: 'Yoga');
      await repository.createHabit(habit);

      final dateStr = '2026-10-21';
      final firstToggle = await repository.toggleHabitCompletion(
        habit.id,
        dateStr,
      );
      expect(firstToggle, isTrue);

      // Verify only 1 completion record exists
      final completions = await repository.getCompletionsForHabit(habit.id);
      expect(completions.length, 1);
      expect(completions.first.dateString, dateStr);
    });

    test(
      'Calculate active streak: consecutive completions up to today',
      () async {
        final habit = Habit(name: 'Deep Reading');
        await repository.createHabit(habit);

        final asOf = DateTime(2026, 10, 21);
        // Completed 3 consecutive days: Oct 19, Oct 20, Oct 21
        await repository.toggleHabitCompletion(habit.id, '2026-10-19');
        await repository.toggleHabitCompletion(habit.id, '2026-10-20');
        await repository.toggleHabitCompletion(habit.id, '2026-10-21');

        final streakResult = await repository.calculateStreak(
          habit.id,
          asOfDate: asOf,
        );
        expect(streakResult.currentStreak, 3);
        expect(streakResult.longestStreak, 3);
        expect(streakResult.isCompletedToday, isTrue);
      },
    );

    test('Preserve streak if completed yesterday but not yet today', () async {
      final habit = Habit(name: 'Walk 10,000 steps');
      await repository.createHabit(habit);

      final asOf = DateTime(2026, 10, 21);
      // Completed Oct 19 and Oct 20, but not Oct 21 (today)
      await repository.toggleHabitCompletion(habit.id, '2026-10-19');
      await repository.toggleHabitCompletion(habit.id, '2026-10-20');

      final streakResult = await repository.calculateStreak(
        habit.id,
        asOfDate: asOf,
      );
      // Streak from yesterday is intact! User has until midnight today
      expect(streakResult.currentStreak, 2);
      expect(streakResult.isCompletedToday, isFalse);
    });

    test('Break current streak if missed yesterday and today', () async {
      final habit = Habit(name: 'Journaling');
      await repository.createHabit(habit);

      final asOf = DateTime(2026, 10, 21);
      // Completed Oct 18 and Oct 19, missed Oct 20 and Oct 21
      await repository.toggleHabitCompletion(habit.id, '2026-10-18');
      await repository.toggleHabitCompletion(habit.id, '2026-10-19');

      final streakResult = await repository.calculateStreak(
        habit.id,
        asOfDate: asOf,
      );
      // Current streak is broken to 0
      expect(streakResult.currentStreak, 0);
      // Longest streak was 2
      expect(streakResult.longestStreak, 2);
    });

    test(
      'Longest streak retains historical personal record across breaks',
      () async {
        final habit = Habit(name: 'Guitar practice');
        await repository.createHabit(habit);

        // Streak 1: 4 days (Oct 1 to Oct 4)
        await repository.toggleHabitCompletion(habit.id, '2026-10-01');
        await repository.toggleHabitCompletion(habit.id, '2026-10-02');
        await repository.toggleHabitCompletion(habit.id, '2026-10-03');
        await repository.toggleHabitCompletion(habit.id, '2026-10-04');

        // Gap: missed Oct 5

        // Streak 2: 2 days (Oct 6 to Oct 7)
        await repository.toggleHabitCompletion(habit.id, '2026-10-06');
        await repository.toggleHabitCompletion(habit.id, '2026-10-07');

        final asOf = DateTime(2026, 10, 7);
        final streakResult = await repository.calculateStreak(
          habit.id,
          asOfDate: asOf,
        );
        expect(streakResult.currentStreak, 2);
        expect(streakResult.longestStreak, 4);
      },
    );
  });
}
