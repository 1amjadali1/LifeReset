import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../logic/app_state.dart';
import 'widgets/daily_priorities_section.dart';
import 'widgets/focus_card.dart';
import 'widgets/habits_summary_section.dart';
import 'widgets/home_header.dart';
import 'widgets/mindful_quote_card.dart';
import 'widgets/social_media_glance_card.dart';

/// The live primary dashboard for Life Reset.
/// Reflects real goals, habits, focus state, and mindful social media awareness.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onNavigateToTab});

  final void Function(int tabIndex) onNavigateToTab;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    return SafeArea(
      child: ListenableBuilder(
        listenable: Listenable.merge([
          appState.goalsController,
          appState.habitsController,
          appState.focusTimerController,
          appState.socialMediaController,
        ]),
        builder: (context, _) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.screenPaddingH,
              vertical: AppDimensions.screenPaddingV,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header (Greeting, Date, App Name, Tagline, Settings)
                const HomeHeader(),
                const SizedBox(height: AppDimensions.spaceL),

                // 2. Real Focus Card
                FocusCard(
                  controller: appState.focusTimerController,
                  onNavigateToFocus: () =>
                      onNavigateToTab(2), // Tab index 2: Focus
                ),
                const SizedBox(height: AppDimensions.spaceL),

                // 3. Real Today's Priorities (0/3)
                DailyPrioritiesSection(
                  controller: appState.goalsController,
                  onNavigateToGoals: () =>
                      onNavigateToTab(1), // Tab index 1: Goals
                ),
                const SizedBox(height: AppDimensions.spaceL),

                // 4. Real Daily Habits
                HabitsSummarySection(
                  controller: appState.habitsController,
                  onNavigateToHabits: () =>
                      onNavigateToTab(3), // Tab index 3: Habits
                ),
                const SizedBox(height: AppDimensions.spaceL),

                // 5. Social Media Awareness Glance
                SocialMediaGlanceCard(
                  controller: appState.socialMediaController,
                  onNavigateToProgress: () =>
                      onNavigateToTab(4), // Tab index 4: Progress
                ),
                const SizedBox(height: AppDimensions.spaceL),

                // 6. Mindful Wellness Reflection
                const MindfulQuoteCard(),
                const SizedBox(height: AppDimensions.spaceXXL),
              ],
            ),
          );
        },
      ),
    );
  }
}
