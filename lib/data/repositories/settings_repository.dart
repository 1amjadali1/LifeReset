import 'dart:convert';

import '../local/app_database.dart';
import '../local/preferences_service.dart';

abstract class SettingsRepository {
  Future<int> getDailySocialMediaLimit();
  Future<void> setDailySocialMediaLimit(int minutes);
  Future<int> getDefaultFocusDuration();
  Future<void> setDefaultFocusDuration(int minutes);
  Future<void> deleteAllAppData();
  Future<String> exportDataAsJson();
}

class AppSettingsRepository implements SettingsRepository {
  AppSettingsRepository({required this.database, required this.preferences});

  final AppDatabase database;
  final PreferencesService preferences;

  @override
  Future<int> getDailySocialMediaLimit() =>
      preferences.getDailySocialMediaLimit();

  @override
  Future<void> setDailySocialMediaLimit(int minutes) =>
      preferences.setDailySocialMediaLimit(minutes);

  @override
  Future<int> getDefaultFocusDuration() =>
      preferences.getDefaultFocusDuration();

  @override
  Future<void> setDefaultFocusDuration(int minutes) =>
      preferences.setDefaultFocusDuration(minutes);

  @override
  Future<void> deleteAllAppData() async {
    await database.deleteAllData();
    await preferences.clearAll();
  }

  @override
  Future<String> exportDataAsJson() async {
    final db = await database.database;
    final goals = await db.query('goals');
    final habits = await db.query('habits');
    final completions = await db.query('habit_completions');
    final focusSessions = await db.query('focus_sessions');
    final socialMedia = await db.query('social_media_entries');

    final dailySocialMediaLimit = await preferences.getDailySocialMediaLimit();
    final defaultFocusDuration = await preferences.getDefaultFocusDuration();

    final exportMap = {
      'app': 'Life Reset',
      'version': '1.0.0',
      'exported_at': DateTime.now().toIso8601String(),
      'preferences': {
        'daily_social_media_limit_minutes': dailySocialMediaLimit,
        'default_focus_duration_minutes': defaultFocusDuration,
      },
      'goals': goals,
      'habits': habits,
      'habit_completions': completions,
      'focus_sessions': focusSessions,
      'social_media_entries': socialMedia,
    };

    return const JsonEncoder.withIndent('  ').convert(exportMap);
  }
}
