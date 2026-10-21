import 'package:flutter/foundation.dart';

import '../data/models/goal.dart';
import '../data/repositories/goal_repository.dart';

class GoalsController extends ChangeNotifier {
  GoalsController(this._repository);

  final GoalRepository _repository;

  List<Goal> _goals = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Goal> get goals => List.unmodifiable(_goals);
  List<Goal> get dailyPriorities =>
      _goals.where((g) => g.isDailyPriority).take(3).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get completedDailyPrioritiesCount =>
      dailyPriorities.where((g) => g.isCompleted).length;

  Future<void> loadGoals() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _goals = await _repository.getAllGoals();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createGoal({
    required String title,
    String? description,
    DateTime? targetDate,
    bool isDailyPriority = false,
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      _errorMessage = 'Goal title cannot be empty.';
      notifyListeners();
      return false;
    }

    if (isDailyPriority) {
      final activeCount = _goals
          .where((g) => g.isDailyPriority && !g.isCompleted)
          .length;
      if (activeCount >= 3) {
        _errorMessage = 'Maximum of 3 active daily priorities allowed.';
        notifyListeners();
        return false;
      }
    }

    final goal = Goal(
      title: trimmedTitle,
      description: description?.trim().isEmpty == true
          ? null
          : description?.trim(),
      targetDate: targetDate,
      isDailyPriority: isDailyPriority,
    );

    try {
      await _repository.createGoal(goal);
      await loadGoals();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleGoal(String id) async {
    try {
      await _repository.toggleGoalCompletion(id);
      await loadGoals();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> updateGoal(Goal goal) async {
    final trimmedTitle = goal.title.trim();
    if (trimmedTitle.isEmpty) {
      _errorMessage = 'Goal title cannot be empty.';
      notifyListeners();
      return false;
    }

    try {
      await _repository.updateGoal(goal.copyWith(title: trimmedTitle));
      await loadGoals();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteGoal(String id) async {
    try {
      await _repository.deleteGoal(id);
      await loadGoals();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
