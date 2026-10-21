import 'package:sqflite/sqflite.dart';

import '../../core/utils/date_utils.dart';
import '../local/app_database.dart';
import '../models/focus_session.dart';

abstract class FocusRepository {
  Future<void> saveSession(FocusSession session);
  Future<List<FocusSession>> getAllSessions();
  Future<List<FocusSession>> getRecentSessions({int limit = 10});
  Future<int> getTotalFocusMinutesForDate(String dateString);
  Future<int> getTotalFocusMinutesForDateRange(DateTime start, DateTime end);
  Future<int> getTotalCompletedSessionsCount();
}

class SqliteFocusRepository implements FocusRepository {
  SqliteFocusRepository(this._database);

  final AppDatabase _database;

  @override
  Future<void> saveSession(FocusSession session) async {
    final db = await _database.database;
    await db.insert(
      'focus_sessions',
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<FocusSession>> getAllSessions() async {
    final db = await _database.database;
    final maps = await db.query('focus_sessions', orderBy: 'completed_at DESC');
    return maps.map(FocusSession.fromMap).toList();
  }

  @override
  Future<List<FocusSession>> getRecentSessions({int limit = 10}) async {
    final db = await _database.database;
    final maps = await db.query(
      'focus_sessions',
      orderBy: 'completed_at DESC',
      limit: limit,
    );
    return maps.map(FocusSession.fromMap).toList();
  }

  @override
  Future<int> getTotalFocusMinutesForDate(String dateString) async {
    final start = '${dateString}T00:00:00';
    final end = '${dateString}T23:59:59.999';
    final db = await _database.database;
    final result = await db.rawQuery(
      '''
      SELECT SUM(actual_elapsed_seconds) as total_seconds
      FROM focus_sessions
      WHERE completed_at >= ? AND completed_at <= ?
      ''',
      [start, end],
    );
    final totalSeconds = Sqflite.firstIntValue(result) ?? 0;
    return (totalSeconds / 60).round();
  }

  @override
  Future<int> getTotalFocusMinutesForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final startIso = AppDateUtils.startOfDay(start).toIso8601String();
    final endIso = DateTime(
      end.year,
      end.month,
      end.day,
      23,
      59,
      59,
      999,
    ).toIso8601String();
    final db = await _database.database;
    final result = await db.rawQuery(
      '''
      SELECT SUM(actual_elapsed_seconds) as total_seconds
      FROM focus_sessions
      WHERE completed_at >= ? AND completed_at <= ?
      ''',
      [startIso, endIso],
    );
    final totalSeconds = Sqflite.firstIntValue(result) ?? 0;
    return (totalSeconds / 60).round();
  }

  @override
  Future<int> getTotalCompletedSessionsCount() async {
    final db = await _database.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM focus_sessions',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
