import 'package:sqflite/sqflite.dart';

import '../../core/utils/date_utils.dart';
import '../local/app_database.dart';
import '../models/habit.dart';
import '../models/habit_completion.dart';

class HabitStreakResult {
  const HabitStreakResult({
    required this.currentStreak,
    required this.longestStreak,
    required this.isCompletedToday,
    required this.totalCompletions,
  });

  final int currentStreak;
  final int longestStreak;
  final bool isCompletedToday;
  final int totalCompletions;
}

abstract class HabitRepository {
  Future<List<Habit>> getActiveHabits();
  Future<List<Habit>> getAllHabits();
  Future<Habit?> getHabitById(String id);
  Future<void> createHabit(Habit habit);
  Future<void> updateHabit(Habit habit);
  Future<void> deleteHabit(String id);
  Future<void> archiveHabit(String id, bool archive);
  Future<bool> isHabitCompletedForDate(String habitId, String dateString);
  Future<bool> toggleHabitCompletion(String habitId, String dateString);
  Future<List<HabitCompletion>> getCompletionsForHabit(String habitId);
  Future<Set<String>> getCompletedHabitIdsForDate(String dateString);
  Future<HabitStreakResult> calculateStreak(
    String habitId, {
    DateTime? asOfDate,
  });
}

class SqliteHabitRepository implements HabitRepository {
  SqliteHabitRepository(this._database);

  final AppDatabase _database;

  @override
  Future<List<Habit>> getActiveHabits() async {
    final db = await _database.database;
    final maps = await db.query(
      'habits',
      where: 'is_archived = 0',
      orderBy: 'created_at ASC',
    );
    return maps.map(Habit.fromMap).toList();
  }

  @override
  Future<List<Habit>> getAllHabits() async {
    final db = await _database.database;
    final maps = await db.query('habits', orderBy: 'created_at ASC');
    return maps.map(Habit.fromMap).toList();
  }

  @override
  Future<Habit?> getHabitById(String id) async {
    final db = await _database.database;
    final maps = await db.query(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Habit.fromMap(maps.first);
  }

  @override
  Future<void> createHabit(Habit habit) async {
    if (habit.name.trim().isEmpty) {
      throw ArgumentError('Habit name cannot be empty.');
    }
    final db = await _database.database;
    await db.insert(
      'habits',
      habit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    if (habit.name.trim().isEmpty) {
      throw ArgumentError('Habit name cannot be empty.');
    }
    final db = await _database.database;
    await db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  @override
  Future<void> deleteHabit(String id) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      await txn.delete(
        'habit_completions',
        where: 'habit_id = ?',
        whereArgs: [id],
      );
      await txn.delete('habits', where: 'id = ?', whereArgs: [id]);
    });
  }

  @override
  Future<void> archiveHabit(String id, bool archive) async {
    final db = await _database.database;
    await db.update(
      'habits',
      {'is_archived': archive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<bool> isHabitCompletedForDate(
    String habitId,
    String dateString,
  ) async {
    final db = await _database.database;
    final maps = await db.query(
      'habit_completions',
      where: 'habit_id = ? AND date_string = ?',
      whereArgs: [habitId, dateString],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  @override
  Future<bool> toggleHabitCompletion(String habitId, String dateString) async {
    final db = await _database.database;
    final isCompleted = await isHabitCompletedForDate(habitId, dateString);

    if (isCompleted) {
      await db.delete(
        'habit_completions',
        where: 'habit_id = ? AND date_string = ?',
        whereArgs: [habitId, dateString],
      );
      return false; // Now uncompleted
    } else {
      final completion = HabitCompletion(
        habitId: habitId,
        dateString: dateString,
      );
      await db.insert(
        'habit_completions',
        completion.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true; // Now completed
    }
  }

  @override
  Future<List<HabitCompletion>> getCompletionsForHabit(String habitId) async {
    final db = await _database.database;
    final maps = await db.query(
      'habit_completions',
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'date_string ASC',
    );
    return maps.map(HabitCompletion.fromMap).toList();
  }

  @override
  Future<Set<String>> getCompletedHabitIdsForDate(String dateString) async {
    final db = await _database.database;
    final maps = await db.query(
      'habit_completions',
      columns: ['habit_id'],
      where: 'date_string = ?',
      whereArgs: [dateString],
    );
    return maps.map((m) => m['habit_id'] as String).toSet();
  }

  @override
  Future<HabitStreakResult> calculateStreak(
    String habitId, {
    DateTime? asOfDate,
  }) async {
    final db = await _database.database;
    final maps = await db.query(
      'habit_completions',
      columns: ['date_string'],
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'date_string ASC',
    );

    if (maps.isEmpty) {
      return const HabitStreakResult(
        currentStreak: 0,
        longestStreak: 0,
        isCompletedToday: false,
        totalCompletions: 0,
      );
    }

    final dates = maps.map((m) => m['date_string'] as String).toSet().toList()
      ..sort();

    final asOf = asOfDate ?? DateTime.now();
    final todayString = AppDateUtils.toDateString(asOf);
    final yesterdayString = AppDateUtils.toDateString(
      asOf.subtract(const Duration(days: 1)),
    );

    final isCompletedToday = dates.contains(todayString);
    final completedSet = dates.toSet();

    // 1. Calculate Current Streak
    int currentStreak = 0;
    DateTime checkDate;

    if (isCompletedToday) {
      checkDate = AppDateUtils.startOfDay(asOf);
    } else if (completedSet.contains(yesterdayString)) {
      // Habit not completed today yet, but streak is preserved from yesterday
      checkDate = AppDateUtils.startOfDay(asOf)
          .subtract(const Duration(days: 1));
    } else {
      // Broken streak
      checkDate = DateTime(1970);
    }

    if (checkDate.year > 1970) {
      while (completedSet.contains(AppDateUtils.toDateString(checkDate))) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }
    }

    // 2. Calculate Longest Streak
    int longestStreak = 0;
    int runningStreak = 0;
    DateTime? prevDate;

    for (final dateStr in dates) {
      final date = AppDateUtils.parseDateString(dateStr);
      if (prevDate == null) {
        runningStreak = 1;
      } else {
        final diff = AppDateUtils.daysBetween(prevDate, date);
        if (diff == 1) {
          runningStreak++;
        } else if (diff > 1) {
          runningStreak = 1;
        }
      }
      if (runningStreak > longestStreak) {
        longestStreak = runningStreak;
      }
      prevDate = date;
    }

    return HabitStreakResult(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      isCompletedToday: isCompletedToday,
      totalCompletions: dates.length,
    );
  }
}
