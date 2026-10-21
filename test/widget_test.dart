import 'package:flutter_test/flutter_test.dart';
import 'package:life_reset/app/life_reset_app.dart';
import 'package:life_reset/core/constants/app_strings.dart';
import 'package:life_reset/data/local/app_database.dart';
import 'package:life_reset/data/local/preferences_service.dart';
import 'package:life_reset/data/models/focus_session.dart';
import 'package:life_reset/data/models/goal.dart';
import 'package:life_reset/data/models/habit.dart';
import 'package:life_reset/data/models/habit_completion.dart';
import 'package:life_reset/data/models/social_media_entry.dart';
import 'package:life_reset/data/repositories/focus_repository.dart';
import 'package:life_reset/data/repositories/goal_repository.dart';
import 'package:life_reset/data/repositories/habit_repository.dart';
import 'package:life_reset/data/repositories/settings_repository.dart';
import 'package:life_reset/data/repositories/social_media_repository.dart';
import 'package:life_reset/logic/app_state.dart';
import 'package:life_reset/logic/focus_timer_controller.dart';
import 'package:life_reset/logic/goals_controller.dart';
import 'package:life_reset/logic/habits_controller.dart';
import 'package:life_reset/logic/progress_controller.dart';
import 'package:life_reset/logic/social_media_controller.dart';

class InMemoryGoalRepo implements GoalRepository {
  final List<Goal> _goals = [];
  @override
  Future<List<Goal>> getAllGoals() async => List.from(_goals);
  @override
  Future<List<Goal>> getDailyPriorities() async =>
      _goals.where((g) => g.isDailyPriority).take(3).toList();
  @override
  Future<Goal?> getGoalById(String id) async =>
      _goals.where((g) => g.id == id).firstOrNull;
  @override
  Future<void> createGoal(Goal goal) async => _goals.add(goal);
  @override
  Future<void> updateGoal(Goal goal) async {
    final idx = _goals.indexWhere((g) => g.id == goal.id);
    if (idx != -1) _goals[idx] = goal;
  }

  @override
  Future<void> deleteGoal(String id) async =>
      _goals.removeWhere((g) => g.id == id);
  @override
  Future<Goal> toggleGoalCompletion(String id) async {
    final goal = await getGoalById(id);
    final updated = goal!.copyWith(isCompleted: !goal.isCompleted);
    await updateGoal(updated);
    return updated;
  }

  @override
  Future<int> getActiveDailyPriorityCount() async =>
      _goals.where((g) => g.isDailyPriority && !g.isCompleted).length;
}

class InMemoryHabitRepo implements HabitRepository {
  final List<Habit> _habits = [];
  final List<HabitCompletion> _completions = [];
  @override
  Future<List<Habit>> getActiveHabits() async =>
      _habits.where((h) => !h.isArchived).toList();
  @override
  Future<List<Habit>> getAllHabits() async => List.from(_habits);
  @override
  Future<Habit?> getHabitById(String id) async =>
      _habits.where((h) => h.id == id).firstOrNull;
  @override
  Future<void> createHabit(Habit habit) async => _habits.add(habit);
  @override
  Future<void> updateHabit(Habit habit) async {
    final idx = _habits.indexWhere((h) => h.id == habit.id);
    if (idx != -1) _habits[idx] = habit;
  }

  @override
  Future<void> deleteHabit(String id) async =>
      _habits.removeWhere((h) => h.id == id);
  @override
  Future<void> archiveHabit(String id, bool archive) async {
    final habit = await getHabitById(id);
    if (habit != null) await updateHabit(habit.copyWith(isArchived: archive));
  }

  @override
  Future<bool> isHabitCompletedForDate(
    String habitId,
    String dateString,
  ) async => _completions.any(
    (c) => c.habitId == habitId && c.dateString == dateString,
  );
  @override
  Future<bool> toggleHabitCompletion(String habitId, String dateString) async {
    final exists = await isHabitCompletedForDate(habitId, dateString);
    if (exists) {
      _completions.removeWhere(
        (c) => c.habitId == habitId && c.dateString == dateString,
      );
      return false;
    } else {
      _completions.add(
        HabitCompletion(habitId: habitId, dateString: dateString),
      );
      return true;
    }
  }

  @override
  Future<List<HabitCompletion>> getCompletionsForHabit(String habitId) async =>
      _completions.where((c) => c.habitId == habitId).toList();
  @override
  Future<Set<String>> getCompletedHabitIdsForDate(String dateString) async =>
      _completions
          .where((c) => c.dateString == dateString)
          .map((c) => c.habitId)
          .toSet();
  @override
  Future<HabitStreakResult> calculateStreak(
    String habitId, {
    DateTime? asOfDate,
  }) async => const HabitStreakResult(
    currentStreak: 0,
    longestStreak: 0,
    isCompletedToday: false,
    totalCompletions: 0,
  );
}

class InMemoryFocusRepo implements FocusRepository {
  final List<FocusSession> _sessions = [];
  @override
  Future<void> saveSession(FocusSession session) async =>
      _sessions.add(session);
  @override
  Future<List<FocusSession>> getAllSessions() async => List.from(_sessions);
  @override
  Future<List<FocusSession>> getRecentSessions({int limit = 10}) async =>
      _sessions.take(limit).toList();
  @override
  Future<int> getTotalFocusMinutesForDate(String dateString) async => 0;
  @override
  Future<int> getTotalFocusMinutesForDateRange(
    DateTime start,
    DateTime end,
  ) async => 0;
  @override
  Future<int> getTotalCompletedSessionsCount() async => _sessions.length;
}

class InMemorySocialMediaRepo implements SocialMediaRepository {
  final List<SocialMediaEntry> _entries = [];
  @override
  Future<void> addEntry(SocialMediaEntry entry) async => _entries.add(entry);
  @override
  Future<void> updateEntry(SocialMediaEntry entry) async {}
  @override
  Future<void> deleteEntry(String id) async =>
      _entries.removeWhere((e) => e.id == id);
  @override
  Future<List<SocialMediaEntry>> getEntriesForDate(String dateString) async =>
      _entries.where((e) => e.dateString == dateString).toList();
  @override
  Future<List<SocialMediaEntry>> getAllEntries() async => List.from(_entries);
  @override
  Future<int> getTotalMinutesForDate(String dateString) async => 0;
  @override
  Future<int> getTotalMinutesForDateRange(DateTime start, DateTime end) async =>
      0;
  @override
  Future<Map<String, int>> getDailyUsageMap(
    DateTime start,
    DateTime end,
  ) async => {};
}

class InMemorySettingsRepo implements SettingsRepository {
  int _limit = 60;
  int _focus = 25;
  @override
  Future<int> getDailySocialMediaLimit() async => _limit;
  @override
  Future<void> setDailySocialMediaLimit(int minutes) async => _limit = minutes;
  @override
  Future<int> getDefaultFocusDuration() async => _focus;
  @override
  Future<void> setDefaultFocusDuration(int minutes) async => _focus = minutes;
  @override
  Future<void> deleteAllAppData() async {}
  @override
  Future<String> exportDataAsJson() async => '{}';
}

void main() {
  testWidgets(
    'Life Reset full app integration: tabs, live state, and navigation',
    (WidgetTester tester) async {
      final goalRepo = InMemoryGoalRepo();
      final habitRepo = InMemoryHabitRepo();
      final focusRepo = InMemoryFocusRepo();
      final socialMediaRepo = InMemorySocialMediaRepo();
      final settingsRepo = InMemorySettingsRepo();

      final goalsCtrl = GoalsController(goalRepo);
      final habitsCtrl = HabitsController(habitRepo);
      final focusCtrl = FocusTimerController(focusRepo);
      final socialMediaCtrl = SocialMediaController(
        repository: socialMediaRepo,
        settingsRepository: settingsRepo,
      );
      final progressCtrl = ProgressController(
        focusRepository: focusRepo,
        socialMediaRepository: socialMediaRepo,
        habitRepository: habitRepo,
        goalRepository: goalRepo,
      );

      final appState = AppState.forTesting(
        database: AppDatabase(),
        preferences: PreferencesService(),
        goalRepository: goalRepo,
        habitRepository: habitRepo,
        focusRepository: focusRepo,
        socialMediaRepository: socialMediaRepo,
        settingsRepository: settingsRepo,
        goalsController: goalsCtrl,
        habitsController: habitsCtrl,
        focusTimerController: focusCtrl,
        socialMediaController: socialMediaCtrl,
        progressController: progressCtrl,
      );

      await appState.reloadAll();

      // 1. Build the Life Reset app
      await tester.pumpWidget(LifeResetApp(appState: appState));
      await tester.pumpAndSettle();

      // 2. Verify identity and branding on Home
      expect(find.text(AppStrings.appName), findsOneWidget);
      expect(find.text(AppStrings.tagline), findsAtLeastNWidgets(1));

      // 3. Verify all 5 navigation tabs are visible
      expect(find.text(AppStrings.navHome), findsOneWidget);
      expect(find.text(AppStrings.navGoals), findsOneWidget);
      expect(find.text(AppStrings.navFocus), findsOneWidget);
      expect(find.text(AppStrings.navHabits), findsOneWidget);
      expect(find.text(AppStrings.navProgress), findsOneWidget);

      // 4. Test tab switching: tap on 'Focus' tab in navigation
      await tester.tap(find.text(AppStrings.navFocus));
      await tester.pumpAndSettle();
      expect(find.text('Focus Timer'), findsOneWidget);
      expect(find.text('Start Focus Session'), findsOneWidget);

      // 5. Test tab switching: tap on 'Goals' tab in navigation
      await tester.tap(find.text(AppStrings.navGoals));
      await tester.pumpAndSettle();
      expect(find.text('Goals'), findsAtLeastNWidgets(1));
      expect(find.text('New Goal'), findsOneWidget);

      // 6. Test tab switching: tap on 'Habits' tab in navigation
      await tester.tap(find.text(AppStrings.navHabits));
      await tester.pumpAndSettle();
      expect(find.text('Habits'), findsAtLeastNWidgets(1));
      expect(find.text('New Habit'), findsOneWidget);

      // 7. Test tab switching: tap on 'Progress' tab in navigation
      await tester.tap(find.text(AppStrings.navProgress));
      await tester.pumpAndSettle();
      expect(find.text('Progress'), findsAtLeastNWidgets(1));
      expect(find.text("Today's Scrolling Time"), findsOneWidget);

      // 8. Return to Home tab
      await tester.tap(find.text(AppStrings.navHome));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.appName), findsOneWidget);
    },
  );
}
