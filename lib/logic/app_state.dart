import 'package:flutter/material.dart';

import '../data/local/app_database.dart';
import '../data/local/preferences_service.dart';
import '../data/repositories/focus_repository.dart';
import '../data/repositories/goal_repository.dart';
import '../data/repositories/habit_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/social_media_repository.dart';
import 'focus_timer_controller.dart';
import 'goals_controller.dart';
import 'habits_controller.dart';
import 'progress_controller.dart';
import 'social_media_controller.dart';

class AppState extends ChangeNotifier {
  AppState._({
    required this.database,
    required this.preferences,
    required this.goalRepository,
    required this.habitRepository,
    required this.focusRepository,
    required this.socialMediaRepository,
    required this.settingsRepository,
    required this.goalsController,
    required this.habitsController,
    required this.focusTimerController,
    required this.socialMediaController,
    required this.progressController,
  });

  /// Factory constructor for testing with mock or in-memory repositories.
  AppState.forTesting({
    required this.database,
    required this.preferences,
    required this.goalRepository,
    required this.habitRepository,
    required this.focusRepository,
    required this.socialMediaRepository,
    required this.settingsRepository,
    required this.goalsController,
    required this.habitsController,
    required this.focusTimerController,
    required this.socialMediaController,
    required this.progressController,
  });

  final AppDatabase database;
  final PreferencesService preferences;
  final GoalRepository goalRepository;
  final HabitRepository habitRepository;
  final FocusRepository focusRepository;
  final SocialMediaRepository socialMediaRepository;
  final SettingsRepository settingsRepository;

  final GoalsController goalsController;
  final HabitsController habitsController;
  final FocusTimerController focusTimerController;
  final SocialMediaController socialMediaController;
  final ProgressController progressController;

  static Future<AppState> create({
    AppDatabase? customDatabase,
    PreferencesService? customPreferences,
  }) async {
    final db = customDatabase ?? AppDatabase();
    final prefs = customPreferences ?? PreferencesService();

    final goalRepo = SqliteGoalRepository(db);
    final habitRepo = SqliteHabitRepository(db);
    final focusRepo = SqliteFocusRepository(db);
    final socialMediaRepo = SqliteSocialMediaRepository(db);
    final settingsRepo = AppSettingsRepository(
      database: db,
      preferences: prefs,
    );

    final goalsCtrl = GoalsController(goalRepo);
    final habitsCtrl = HabitsController(habitRepo);
    final focusCtrl = FocusTimerController(focusRepo, prefs);
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

    final appState = AppState._(
      database: db,
      preferences: prefs,
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

    // Initial load across all feature controllers
    await appState.reloadAll();

    return appState;
  }

  /// Reloads all data controllers from local storage sequentially to ensure DB safety.
  Future<void> reloadAll() async {
    await goalsController.loadGoals();
    await habitsController.loadHabits();
    await focusTimerController.loadTodayStats();
    await focusTimerController.restoreTimerState();
    await socialMediaController.loadData();
    await progressController.loadWeeklyReport();
    notifyListeners();
  }

  /// Completely wipes all user data and refreshes all controllers.
  Future<void> deleteAllData() async {
    await settingsRepository.deleteAllAppData();
    focusTimerController.cancelTimer();
    await reloadAll();
  }
}

/// An InheritedWidget providing access to [AppState] throughout the widget tree.
class AppStateScope extends InheritedWidget {
  const AppStateScope({
    super.key,
    required this.appState,
    required super.child,
  });

  final AppState appState;

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'No AppStateScope found in context.');
    return scope!.appState;
  }

  @override
  bool updateShouldNotify(AppStateScope oldWidget) =>
      appState != oldWidget.appState;
}
