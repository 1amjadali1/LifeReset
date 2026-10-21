import 'package:sqflite/sqflite.dart';

import '../local/app_database.dart';
import '../models/goal.dart';

abstract class GoalRepository {
  Future<List<Goal>> getAllGoals();
  Future<List<Goal>> getDailyPriorities();
  Future<Goal?> getGoalById(String id);
  Future<void> createGoal(Goal goal);
  Future<void> updateGoal(Goal goal);
  Future<void> deleteGoal(String id);
  Future<Goal> toggleGoalCompletion(String id);
  Future<int> getActiveDailyPriorityCount();
}

class SqliteGoalRepository implements GoalRepository {
  SqliteGoalRepository(this._database);

  final AppDatabase _database;

  @override
  Future<List<Goal>> getAllGoals() async {
    final db = await _database.database;
    final maps = await db.query(
      'goals',
      orderBy: 'is_completed ASC, is_daily_priority DESC, created_at DESC',
    );
    return maps.map(Goal.fromMap).toList();
  }

  @override
  Future<List<Goal>> getDailyPriorities() async {
    final db = await _database.database;
    final maps = await db.query(
      'goals',
      where: 'is_daily_priority = 1',
      orderBy: 'is_completed ASC, created_at DESC',
      limit: 3,
    );
    return maps.map(Goal.fromMap).toList();
  }

  @override
  Future<Goal?> getGoalById(String id) async {
    final db = await _database.database;
    final maps = await db.query(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Goal.fromMap(maps.first);
  }

  @override
  Future<void> createGoal(Goal goal) async {
    if (goal.title.trim().isEmpty) {
      throw ArgumentError('Goal title cannot be empty.');
    }
    final db = await _database.database;
    await db.insert(
      'goals',
      goal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateGoal(Goal goal) async {
    if (goal.title.trim().isEmpty) {
      throw ArgumentError('Goal title cannot be empty.');
    }
    final db = await _database.database;
    await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  @override
  Future<void> deleteGoal(String id) async {
    final db = await _database.database;
    await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<Goal> toggleGoalCompletion(String id) async {
    final goal = await getGoalById(id);
    if (goal == null) {
      throw ArgumentError('Goal not found: $id');
    }
    final updated = goal.copyWith(
      isCompleted: !goal.isCompleted,
      completedAt: !goal.isCompleted ? DateTime.now() : null,
    );
    await updateGoal(updated);
    return updated;
  }

  @override
  Future<int> getActiveDailyPriorityCount() async {
    final db = await _database.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM goals WHERE is_daily_priority = 1 AND is_completed = 0',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
