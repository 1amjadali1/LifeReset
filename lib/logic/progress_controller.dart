import 'package:flutter/foundation.dart';

import '../core/utils/date_utils.dart';
import '../data/repositories/focus_repository.dart';
import '../data/repositories/goal_repository.dart';
import '../data/repositories/habit_repository.dart';
import '../data/repositories/social_media_repository.dart';

class DailyProgressMetric {
  const DailyProgressMetric({
    required this.date,
    required this.dateString,
    required this.dayLabel,
    required this.focusMinutes,
    required this.socialMediaMinutes,
    required this.habitsCompletedCount,
  });

  final DateTime date;
  final String dateString;
  final String dayLabel;
  final int focusMinutes;
  final int socialMediaMinutes;
  final int habitsCompletedCount;
}

class ProgressReport {
  const ProgressReport({
    required this.dailyMetrics,
    required this.totalFocusMinutes,
    required this.totalSocialMediaMinutes,
    required this.totalHabitCompletions,
    required this.totalGoalsCompleted,
    required this.habitConsistencyRate,
    required this.hasAnyData,
  });

  final List<DailyProgressMetric> dailyMetrics;
  final int totalFocusMinutes;
  final int totalSocialMediaMinutes;
  final int totalHabitCompletions;
  final int totalGoalsCompleted;
  final double habitConsistencyRate; // 0.0 to 1.0
  final bool hasAnyData;
}

class ProgressController extends ChangeNotifier {
  ProgressController({
    required this.focusRepository,
    required this.socialMediaRepository,
    required this.habitRepository,
    required this.goalRepository,
  });

  final FocusRepository focusRepository;
  final SocialMediaRepository socialMediaRepository;
  final HabitRepository habitRepository;
  final GoalRepository goalRepository;

  ProgressReport? _report;
  bool _isLoading = false;
  String? _errorMessage;

  ProgressReport? get report => _report;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadWeeklyReport() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final today = AppDateUtils.startOfDay(now);
      const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

      final List<DailyProgressMetric> metrics = [];
      int totalFocus = 0;
      int totalSocial = 0;
      int totalHabitCompletions = 0;

      final activeHabits = await habitRepository.getActiveHabits();
      final allGoals = await goalRepository.getAllGoals();
      final totalGoalsCompleted = allGoals.where((g) => g.isCompleted).length;

      // Iterate past 7 days (from 6 days ago up to today)
      for (int i = 6; i >= 0; i--) {
        final date = today.subtract(Duration(days: i));
        final dateStr = AppDateUtils.toDateString(date);
        final dayLabel = dayNames[date.weekday - 1];

        final focusMins = await focusRepository.getTotalFocusMinutesForDate(
          dateStr,
        );
        final socialMins = await socialMediaRepository.getTotalMinutesForDate(
          dateStr,
        );
        final habitCompletions = await habitRepository
            .getCompletedHabitIdsForDate(dateStr);

        totalFocus += focusMins;
        totalSocial += socialMins;
        totalHabitCompletions += habitCompletions.length;

        metrics.add(
          DailyProgressMetric(
            date: date,
            dateString: dateStr,
            dayLabel: dayLabel,
            focusMinutes: focusMins,
            socialMediaMinutes: socialMins,
            habitsCompletedCount: habitCompletions.length,
          ),
        );
      }

      final int possibleHabitOpportunities = activeHabits.length * 7;
      final double consistency = possibleHabitOpportunities > 0
          ? (totalHabitCompletions / possibleHabitOpportunities).clamp(0.0, 1.0)
          : 0.0;

      final hasData =
          totalFocus > 0 ||
          totalSocial > 0 ||
          totalHabitCompletions > 0 ||
          totalGoalsCompleted > 0;

      _report = ProgressReport(
        dailyMetrics: metrics,
        totalFocusMinutes: totalFocus,
        totalSocialMediaMinutes: totalSocial,
        totalHabitCompletions: totalHabitCompletions,
        totalGoalsCompleted: totalGoalsCompleted,
        habitConsistencyRate: consistency,
        hasAnyData: hasData,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
