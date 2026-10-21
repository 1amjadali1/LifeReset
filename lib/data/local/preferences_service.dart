import 'package:shared_preferences/shared_preferences.dart';

/// Manages key-value configuration and app preferences.
class PreferencesService {
  PreferencesService({SharedPreferences? preferences}) : _prefs = preferences;

  SharedPreferences? _prefs;

  static const String _keyDailySocialMediaLimit =
      'daily_social_media_limit_minutes';
  static const String _keyDefaultFocusDuration =
      'default_focus_duration_minutes';

  // Active focus timer persistence keys
  static const String _keyTimerStatus = 'active_timer_status';
  static const String _keyTimerTargetMinutes = 'active_timer_target_minutes';
  static const String _keyTimerAccumulatedSeconds =
      'active_timer_accumulated_seconds';
  static const String _keyTimerSegmentStartMs = 'active_timer_segment_start_ms';
  static const String _keyTimerSessionStartMs = 'active_timer_session_start_ms';
  static const String _keyTimerLinkedGoalId = 'active_timer_linked_goal_id';
  static const String _keyTimerSessionLabel = 'active_timer_session_label';

  Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Returns the user's daily social-media limit in minutes (default: 60).
  Future<int> getDailySocialMediaLimit() async {
    final prefs = await _instance;
    return prefs.getInt(_keyDailySocialMediaLimit) ?? 60;
  }

  /// Sets the user's daily social-media limit in minutes.
  Future<void> setDailySocialMediaLimit(int minutes) async {
    final prefs = await _instance;
    await prefs.setInt(_keyDailySocialMediaLimit, minutes);
  }

  /// Returns default focus duration in minutes (default: 25).
  Future<int> getDefaultFocusDuration() async {
    final prefs = await _instance;
    return prefs.getInt(_keyDefaultFocusDuration) ?? 25;
  }

  /// Sets default focus duration in minutes.
  Future<void> setDefaultFocusDuration(int minutes) async {
    final prefs = await _instance;
    await prefs.setInt(_keyDefaultFocusDuration, minutes);
  }

  /// Persists active timer state so in-progress sessions survive app restart.
  Future<void> saveActiveTimerState({
    required String status,
    required int targetMinutes,
    required int accumulatedSeconds,
    int? segmentStartMs,
    int? sessionStartMs,
    String? linkedGoalId,
    String? sessionLabel,
  }) async {
    final prefs = await _instance;
    await prefs.setString(_keyTimerStatus, status);
    await prefs.setInt(_keyTimerTargetMinutes, targetMinutes);
    await prefs.setInt(_keyTimerAccumulatedSeconds, accumulatedSeconds);
    if (segmentStartMs != null) {
      await prefs.setInt(_keyTimerSegmentStartMs, segmentStartMs);
    } else {
      await prefs.remove(_keyTimerSegmentStartMs);
    }
    if (sessionStartMs != null) {
      await prefs.setInt(_keyTimerSessionStartMs, sessionStartMs);
    } else {
      await prefs.remove(_keyTimerSessionStartMs);
    }
    if (linkedGoalId != null) {
      await prefs.setString(_keyTimerLinkedGoalId, linkedGoalId);
    } else {
      await prefs.remove(_keyTimerLinkedGoalId);
    }
    if (sessionLabel != null) {
      await prefs.setString(_keyTimerSessionLabel, sessionLabel);
    } else {
      await prefs.remove(_keyTimerSessionLabel);
    }
  }

  /// Retrieves persisted active timer state, or `null` if no timer is active.
  Future<Map<String, dynamic>?> getActiveTimerState() async {
    final prefs = await _instance;
    final status = prefs.getString(_keyTimerStatus);
    if (status == null) return null;

    return {
      'status': status,
      'targetMinutes': prefs.getInt(_keyTimerTargetMinutes) ?? 25,
      'accumulatedSeconds': prefs.getInt(_keyTimerAccumulatedSeconds) ?? 0,
      'segmentStartMs': prefs.getInt(_keyTimerSegmentStartMs),
      'sessionStartMs': prefs.getInt(_keyTimerSessionStartMs),
      'linkedGoalId': prefs.getString(_keyTimerLinkedGoalId),
      'sessionLabel': prefs.getString(_keyTimerSessionLabel),
    };
  }

  /// Clears persisted active timer state when a session completes or cancels.
  Future<void> clearActiveTimerState() async {
    final prefs = await _instance;
    await prefs.remove(_keyTimerStatus);
    await prefs.remove(_keyTimerTargetMinutes);
    await prefs.remove(_keyTimerAccumulatedSeconds);
    await prefs.remove(_keyTimerSegmentStartMs);
    await prefs.remove(_keyTimerSessionStartMs);
    await prefs.remove(_keyTimerLinkedGoalId);
    await prefs.remove(_keyTimerSessionLabel);
  }

  /// Clears all stored preferences.
  Future<void> clearAll() async {
    final prefs = await _instance;
    await prefs.clear();
  }
}
