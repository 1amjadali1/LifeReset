import 'package:sqflite/sqflite.dart';

import '../../core/utils/date_utils.dart';
import '../local/app_database.dart';
import '../models/social_media_entry.dart';

abstract class SocialMediaRepository {
  Future<void> addEntry(SocialMediaEntry entry);
  Future<void> updateEntry(SocialMediaEntry entry);
  Future<void> deleteEntry(String id);
  Future<List<SocialMediaEntry>> getEntriesForDate(String dateString);
  Future<List<SocialMediaEntry>> getAllEntries();
  Future<int> getTotalMinutesForDate(String dateString);
  Future<int> getTotalMinutesForDateRange(DateTime start, DateTime end);
  Future<Map<String, int>> getDailyUsageMap(DateTime start, DateTime end);
}

class SqliteSocialMediaRepository implements SocialMediaRepository {
  SqliteSocialMediaRepository(this._database);

  final AppDatabase _database;

  @override
  Future<void> addEntry(SocialMediaEntry entry) async {
    if (entry.appName.trim().isEmpty) {
      throw ArgumentError('App name cannot be empty.');
    }
    if (entry.durationMinutes <= 0) {
      throw ArgumentError('Duration must be greater than zero.');
    }
    final db = await _database.database;
    await db.insert(
      'social_media_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateEntry(SocialMediaEntry entry) async {
    if (entry.appName.trim().isEmpty) {
      throw ArgumentError('App name cannot be empty.');
    }
    if (entry.durationMinutes <= 0) {
      throw ArgumentError('Duration must be greater than zero.');
    }
    final db = await _database.database;
    await db.update(
      'social_media_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  @override
  Future<void> deleteEntry(String id) async {
    final db = await _database.database;
    await db.delete('social_media_entries', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<SocialMediaEntry>> getEntriesForDate(String dateString) async {
    final db = await _database.database;
    final maps = await db.query(
      'social_media_entries',
      where: 'date_string = ?',
      whereArgs: [dateString],
      orderBy: 'logged_at DESC',
    );
    return maps.map(SocialMediaEntry.fromMap).toList();
  }

  @override
  Future<List<SocialMediaEntry>> getAllEntries() async {
    final db = await _database.database;
    final maps = await db.query(
      'social_media_entries',
      orderBy: 'date_string DESC, logged_at DESC',
    );
    return maps.map(SocialMediaEntry.fromMap).toList();
  }

  @override
  Future<int> getTotalMinutesForDate(String dateString) async {
    final db = await _database.database;
    final result = await db.rawQuery(
      '''
      SELECT SUM(duration_minutes) as total_minutes
      FROM social_media_entries
      WHERE date_string = ?
      ''',
      [dateString],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<int> getTotalMinutesForDateRange(DateTime start, DateTime end) async {
    final startStr = AppDateUtils.toDateString(start);
    final endStr = AppDateUtils.toDateString(end);
    final db = await _database.database;
    final result = await db.rawQuery(
      '''
      SELECT SUM(duration_minutes) as total_minutes
      FROM social_media_entries
      WHERE date_string >= ? AND date_string <= ?
      ''',
      [startStr, endStr],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<Map<String, int>> getDailyUsageMap(
    DateTime start,
    DateTime end,
  ) async {
    final startStr = AppDateUtils.toDateString(start);
    final endStr = AppDateUtils.toDateString(end);
    final db = await _database.database;
    final result = await db.rawQuery(
      '''
      SELECT date_string, SUM(duration_minutes) as total
      FROM social_media_entries
      WHERE date_string >= ? AND date_string <= ?
      GROUP BY date_string
      ''',
      [startStr, endStr],
    );

    final map = <String, int>{};
    for (final row in result) {
      final date = row['date_string'] as String;
      final total = (row['total'] as num).toInt();
      map[date] = total;
    }
    return map;
  }
}
