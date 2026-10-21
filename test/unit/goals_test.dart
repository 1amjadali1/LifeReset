import 'package:flutter_test/flutter_test.dart';
import 'package:life_reset/data/local/app_database.dart';
import 'package:life_reset/data/models/goal.dart';
import 'package:life_reset/data/repositories/goal_repository.dart';
import 'package:life_reset/logic/goals_controller.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Goal Repository and Controller Tests', () {
    late AppDatabase appDb;
    late GoalRepository repository;
    late GoalsController controller;

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
          },
        ),
      );
      appDb = AppDatabase(database: db);
      repository = SqliteGoalRepository(appDb);
      controller = GoalsController(repository);
      await controller.loadGoals();
    });

    tearDown(() async {
      await appDb.close();
    });

    test('Create and retrieve goal successfully', () async {
      final created = await controller.createGoal(
        title: 'Complete Flutter architecture',
        description: 'Implement local SQLite models',
      );
      expect(created, isTrue);
      expect(controller.goals.length, 1);
      expect(controller.goals.first.title, 'Complete Flutter architecture');
      expect(controller.goals.first.isCompleted, isFalse);
    });

    test('Reject empty or whitespace-only goal title', () async {
      final created = await controller.createGoal(title: '   ');
      expect(created, isFalse);
      expect(controller.errorMessage, isNotNull);
      expect(controller.goals, isEmpty);
    });

    test('Toggle goal completion updates state and timestamps', () async {
      await controller.createGoal(title: 'Read 20 pages');
      final goal = controller.goals.first;

      await controller.toggleGoal(goal.id);
      expect(controller.goals.first.isCompleted, isTrue);
      expect(controller.goals.first.completedAt, isNotNull);

      // Toggle back to incomplete
      await controller.toggleGoal(goal.id);
      expect(controller.goals.first.isCompleted, isFalse);
      expect(controller.goals.first.completedAt, isNull);
    });

    test('Enforce maximum 3 active daily priorities', () async {
      expect(
        await controller.createGoal(title: 'Priority 1', isDailyPriority: true),
        isTrue,
      );
      expect(
        await controller.createGoal(title: 'Priority 2', isDailyPriority: true),
        isTrue,
      );
      expect(
        await controller.createGoal(title: 'Priority 3', isDailyPriority: true),
        isTrue,
      );

      // Attempting 4th active priority should be rejected
      final fourth = await controller.createGoal(
        title: 'Priority 4',
        isDailyPriority: true,
      );
      expect(fourth, isFalse);
      expect(controller.errorMessage, contains('Maximum of 3'));

      // If one is completed, another priority can be added
      await controller.toggleGoal(controller.dailyPriorities.first.id);
      final allowedNow = await controller.createGoal(
        title: 'Priority 4 Allowed',
        isDailyPriority: true,
      );
      expect(allowedNow, isTrue);
    });

    test('Detect overdue target date correctly', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final overdueGoal = Goal(
        title: 'Submit taxes',
        targetDate: yesterday,
        isCompleted: false,
      );
      expect(overdueGoal.isOverdue, isTrue);

      final completedOverdueGoal = overdueGoal.copyWith(isCompleted: true);
      expect(completedOverdueGoal.isOverdue, isFalse);
    });

    test('Delete goal removes record permanently', () async {
      await controller.createGoal(title: 'Temporary Goal');
      final goalId = controller.goals.first.id;

      await controller.deleteGoal(goalId);
      expect(controller.goals, isEmpty);
    });
  });
}
