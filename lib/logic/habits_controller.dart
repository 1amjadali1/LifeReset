import 'package:flutter/foundation.dart';

import '../core/utils/date_utils.dart';
import '../data/models/habit.dart';
import '../data/repositories/habit_repository.dart';

class HabitsController extends ChangeNotifier {
  HabitsController(this._repository);

  final HabitRepository _repository;

  List<Habit> _habits = [];
  Set<String> _completedTodayIds = {};
  Map<String, HabitStreakResult> _streaks = {};
  bool _isLoading = false;
  String? _errorMessage;

  List<Habit> get habits => List.unmodifiable(_habits);
  Set<String> get completedTodayIds => Set.unmodifiable(_completedTodayIds);
  Map<String, HabitStreakResult> get streaks => Map.unmodifiable(_streaks);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get completedTodayCount => _completedTodayIds.length;
  int get totalActiveCount => _habits.length;

  HabitStreakResult? getStreak(String habitId) => _streaks[habitId];

  Future<void> loadHabits() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _habits = await _repository.getActiveHabits();
      final todayStr = AppDateUtils.todayString;
      _completedTodayIds = await _repository.getCompletedHabitIdsForDate(
        todayStr,
      );

      final Map<String, HabitStreakResult> newStreaks = {};
      for (final habit in _habits) {
        newStreaks[habit.id] = await _repository.calculateStreak(habit.id);
      }
      _streaks = newStreaks;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createHabit({
    required String name,
    String? description,
    int? iconCodePoint,
    String? colorHex,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      _errorMessage = 'Habit name cannot be empty.';
      notifyListeners();
      return false;
    }

    final habit = Habit(
      name: trimmedName,
      description: description?.trim().isEmpty == true
          ? null
          : description?.trim(),
      iconCodePoint: iconCodePoint,
      colorHex: colorHex,
    );

    try {
      await _repository.createHabit(habit);
      await loadHabits();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleCompletion(String habitId, {DateTime? date}) async {
    final targetDateStr = date != null
        ? AppDateUtils.toDateString(date)
        : AppDateUtils.todayString;

    try {
      await _repository.toggleHabitCompletion(habitId, targetDateStr);
      await loadHabits();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteHabit(String id) async {
    try {
      await _repository.deleteHabit(id);
      await loadHabits();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> archiveHabit(String id) async {
    try {
      await _repository.archiveHabit(id, true);
      await loadHabits();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
