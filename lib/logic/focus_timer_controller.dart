import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/local/preferences_service.dart';
import '../data/models/focus_session.dart';
import '../data/repositories/focus_repository.dart';

enum FocusTimerStatus { idle, running, paused, completed }

class FocusTimerController extends ChangeNotifier {
  FocusTimerController(this._repository, [this._preferences]);

  final FocusRepository _repository;
  final PreferencesService? _preferences;

  FocusTimerStatus _status = FocusTimerStatus.idle;
  int _targetDurationMinutes = 25;
  Duration _accumulatedElapsed = Duration.zero;
  DateTime? _currentSegmentStart;
  DateTime? _sessionStart;
  Timer? _ticker;
  bool _hasSavedSession = false;

  String? _linkedGoalId;
  String? _sessionLabel;
  int _totalCompletedSessionsToday = 0;
  int _totalFocusMinutesToday = 0;

  FocusTimerStatus get status => _status;
  int get targetDurationMinutes => _targetDurationMinutes;
  int get targetDurationSeconds => _targetDurationMinutes * 60;
  String? get linkedGoalId => _linkedGoalId;
  String? get sessionLabel => _sessionLabel;
  int get totalCompletedSessionsToday => _totalCompletedSessionsToday;
  int get totalFocusMinutesToday => _totalFocusMinutesToday;

  bool get isRunning => _status == FocusTimerStatus.running;
  bool get isPaused => _status == FocusTimerStatus.paused;
  bool get isCompleted => _status == FocusTimerStatus.completed;
  bool get isIdle => _status == FocusTimerStatus.idle;

  /// Calculates total elapsed seconds strictly using wall-clock timestamps.
  int get elapsedSeconds {
    var total = _accumulatedElapsed;
    if (_status == FocusTimerStatus.running && _currentSegmentStart != null) {
      total += DateTime.now().difference(_currentSegmentStart!);
    }
    return total.inSeconds.clamp(0, targetDurationSeconds);
  }

  /// Calculates remaining seconds from target duration and elapsed seconds.
  int get remainingSeconds {
    final remaining = targetDurationSeconds - elapsedSeconds;
    return remaining.clamp(0, targetDurationSeconds);
  }

  /// Progress fraction from 0.0 to 1.0.
  double get progressFraction {
    if (targetDurationSeconds <= 0) return 0.0;
    return (elapsedSeconds / targetDurationSeconds).clamp(0.0, 1.0);
  }

  /// Formatted remaining time `MM:SS`.
  String get formattedRemainingTime {
    final rem = remainingSeconds;
    final minutes = (rem ~/ 60).toString().padLeft(2, '0');
    final seconds = (rem % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> loadTodayStats() async {
    final now = DateTime.now();
    final todayStr =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    _totalFocusMinutesToday = await _repository.getTotalFocusMinutesForDate(
      todayStr,
    );
    _totalCompletedSessionsToday = await _repository
        .getTotalCompletedSessionsCount();
    notifyListeners();
  }

  void setDurationMinutes(int minutes) {
    if (_status != FocusTimerStatus.idle) return;
    _targetDurationMinutes = minutes.clamp(1, 180);
    notifyListeners();
  }

  void setLinkedGoal(String? goalId) {
    _linkedGoalId = goalId;
    notifyListeners();
  }

  void setSessionLabel(String? label) {
    _sessionLabel = label?.trim().isEmpty == true ? null : label?.trim();
    notifyListeners();
  }

  Future<void> startTimer() async {
    if (_status == FocusTimerStatus.running) return;

    final now = DateTime.now();
    _sessionStart = now;
    _currentSegmentStart = now;
    _accumulatedElapsed = Duration.zero;
    _hasSavedSession = false;
    _status = FocusTimerStatus.running;

    _startTicker();
    await _persistState();
    notifyListeners();
  }

  Future<void> pauseTimer() async {
    if (_status != FocusTimerStatus.running) return;

    if (_currentSegmentStart != null) {
      _accumulatedElapsed += DateTime.now().difference(_currentSegmentStart!);
      _currentSegmentStart = null;
    }
    _status = FocusTimerStatus.paused;
    _stopTicker();
    await _persistState();
    notifyListeners();
  }

  Future<void> resumeTimer() async {
    if (_status != FocusTimerStatus.paused) return;

    _currentSegmentStart = DateTime.now();
    _status = FocusTimerStatus.running;
    _startTicker();
    await _persistState();
    notifyListeners();
  }

  Future<void> cancelTimer() async {
    _stopTicker();
    _status = FocusTimerStatus.idle;
    _accumulatedElapsed = Duration.zero;
    _currentSegmentStart = null;
    _sessionStart = null;
    _hasSavedSession = false;
    await _clearPersistedState();
    notifyListeners();
  }

  Future<void> resetAfterCompletion() async {
    _stopTicker();
    _status = FocusTimerStatus.idle;
    _accumulatedElapsed = Duration.zero;
    _currentSegmentStart = null;
    _sessionStart = null;
    _hasSavedSession = false;
    await _clearPersistedState();
    notifyListeners();
  }

  /// Restores any in-progress or paused timer from local preferences across app restart.
  Future<void> restoreTimerState() async {
    if (_preferences == null) return;
    try {
      final state = await _preferences.getActiveTimerState();
      if (state == null) return;

      final statusStr = state['status'] as String?;
      final targetMinutes = state['targetMinutes'] as int? ?? 25;
      final accumulatedSeconds = state['accumulatedSeconds'] as int? ?? 0;
      final segmentStartMs = state['segmentStartMs'] as int?;
      final sessionStartMs = state['sessionStartMs'] as int?;
      final linkedGoalId = state['linkedGoalId'] as String?;
      final sessionLabel = state['sessionLabel'] as String?;

      if (statusStr == 'paused') {
        _status = FocusTimerStatus.paused;
        _targetDurationMinutes = targetMinutes;
        _accumulatedElapsed = Duration(seconds: accumulatedSeconds);
        _sessionStart = sessionStartMs != null
            ? DateTime.fromMillisecondsSinceEpoch(sessionStartMs)
            : null;
        _linkedGoalId = linkedGoalId;
        _sessionLabel = sessionLabel;
        notifyListeners();
      } else if (statusStr == 'running') {
        _targetDurationMinutes = targetMinutes;
        _linkedGoalId = linkedGoalId;
        _sessionLabel = sessionLabel;
        _sessionStart = sessionStartMs != null
            ? DateTime.fromMillisecondsSinceEpoch(sessionStartMs)
            : null;

        if (segmentStartMs != null) {
          final segStart = DateTime.fromMillisecondsSinceEpoch(segmentStartMs);
          final runningSegment = DateTime.now().difference(segStart);
          final totalElapsed =
              Duration(seconds: accumulatedSeconds) + runningSegment;

          if (totalElapsed.inSeconds >= targetDurationSeconds) {
            // Completed while the app was closed
            _accumulatedElapsed = Duration(seconds: targetDurationSeconds);
            await _completeSession();
          } else {
            // Still in progress
            _accumulatedElapsed = Duration(seconds: accumulatedSeconds);
            _currentSegmentStart = segStart;
            _status = FocusTimerStatus.running;
            _startTicker();
            notifyListeners();
          }
        }
      }
    } catch (e) {
      debugPrint('Error restoring timer state: $e');
      _clearPersistedState();
    }
  }

  Future<void> _persistState() async {
    if (_preferences == null) return;
    try {
      await _preferences.saveActiveTimerState(
        status: _status.name,
        targetMinutes: _targetDurationMinutes,
        accumulatedSeconds: _accumulatedElapsed.inSeconds,
        segmentStartMs: _currentSegmentStart?.millisecondsSinceEpoch,
        sessionStartMs: _sessionStart?.millisecondsSinceEpoch,
        linkedGoalId: _linkedGoalId,
        sessionLabel: _sessionLabel,
      );
    } catch (e) {
      debugPrint('Failed to save active timer state: $e');
    }
  }

  Future<void> _clearPersistedState() async {
    if (_preferences == null) return;
    try {
      await _preferences.clearActiveTimerState();
    } catch (e) {
      debugPrint('Failed to clear active timer state: $e');
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _onTick();
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _onTick() {
    if (_status != FocusTimerStatus.running) return;

    if (remainingSeconds <= 0) {
      _completeSession();
    } else {
      notifyListeners();
    }
  }

  Future<void> _completeSession() async {
    _stopTicker();
    _status = FocusTimerStatus.completed;
    _clearPersistedState();

    if (!_hasSavedSession) {
      _hasSavedSession = true;
      final session = FocusSession(
        durationMinutes: _targetDurationMinutes,
        actualElapsedSeconds: targetDurationSeconds,
        goalId: _linkedGoalId,
        label: _sessionLabel,
        startedAt:
            _sessionStart ??
            DateTime.now().subtract(Duration(minutes: _targetDurationMinutes)),
        completedAt: DateTime.now(),
      );

      try {
        await _repository.saveSession(session);
        await loadTodayStats();
      } catch (e) {
        debugPrint('Error saving completed focus session: $e');
      }
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }
}
