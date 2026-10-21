import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/empty_state_card.dart';
import '../../../data/models/habit.dart';
import '../../../logic/app_state.dart';
import 'widgets/create_habit_sheet.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  void _openCreateSheet(BuildContext context, {Habit? existingHabit}) {
    final appState = AppStateScope.of(context);
    CreateHabitSheet.show(
      context: context,
      existingHabit: existingHabit,
      onSave:
          ({
            required String name,
            String? description,
            int? iconCodePoint,
          }) async {
            return await appState.habitsController.createHabit(
              name: name,
              description: description,
              iconCodePoint: iconCodePoint,
            );
          },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Habit habit) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete Habit?',
      message:
          'Are you sure you want to delete "${habit.name}"? All streak history for this habit will be removed.',
      confirmLabel: 'Delete',
    );
    if (confirmed && context.mounted) {
      final appState = AppStateScope.of(context);
      await appState.habitsController.deleteHabit(habit.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final controller = appState.habitsController;

    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final habits = controller.habits;
            final completedCount = controller.completedTodayCount;
            final totalCount = controller.totalActiveCount;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPaddingH,
                vertical: AppDimensions.screenPaddingV,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Habits', style: AppTypography.displayLarge),
                          const SizedBox(height: 2),
                          Text(
                            'Consistency beats intensity every day.',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                      AppButton(
                        label: 'New Habit',
                        icon: Icons.add,
                        isFullWidth: false,
                        onPressed: () => _openCreateSheet(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spaceL),

                  // Today's Habit Progress Card
                  if (totalCount > 0) ...[
                    AppCard(
                      backgroundColor: AppColors.accentSurface,
                      borderColor: AppColors.lightGreenAccent.withValues(
                        alpha: 0.6,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Today's Habit Progress",
                                style: AppTypography.labelLarge.copyWith(
                                  color: AppColors.primaryForestGreen,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                completedCount == totalCount
                                    ? 'All habits completed for today!'
                                    : '$completedCount of $totalCount completed so far',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.primaryForestGreen
                                      .withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spaceS + 4,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.badgeBackground,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusFull,
                              ),
                            ),
                            child: Text(
                              '$completedCount / $totalCount',
                              style: AppTypography.badgeText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceL),
                  ],

                  // Error Banner
                  if (controller.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.spaceM),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM,
                        ),
                      ),
                      child: Text(
                        controller.errorMessage!,
                        style: AppTypography.bodySmall.copyWith(
                          color: const Color(0xFFC62828),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceM),
                  ],

                  // Habits List or Empty State
                  if (habits.isEmpty)
                    const EmptyStateCard(
                      icon: Icons.repeat_rounded,
                      title: 'No Habits Created Yet',
                      description: 'Build positive momentum by creating simple, daily habits. Tap "New Habit" to start.',
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: habits.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppDimensions.spaceM),
                      itemBuilder: (context, index) {
                        final habit = habits[index];
                        return _buildHabitCard(context, habit, controller);
                      },
                    ),
                  const SizedBox(height: AppDimensions.spaceXXL),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHabitCard(
    BuildContext context,
    Habit habit,
    dynamic controller,
  ) {
    final isCompletedToday = controller.completedTodayIds.contains(habit.id);
    final streak = controller.getStreak(habit.id);
    final currentStreak = streak?.currentStreak ?? 0;
    final longestStreak = streak?.longestStreak ?? 0;

    final iconData = AppIcons.getHabitIcon(habit.iconCodePoint);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Habit Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isCompletedToday
                      ? AppColors.badgeBackground
                      : AppColors.accentSurface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Icon(
                  iconData,
                  size: 22,
                  color: AppColors.primaryForestGreen,
                ),
              ),
              const SizedBox(width: AppDimensions.spaceM),

              // Habit Name & Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: AppTypography.headlineSmall.copyWith(fontSize: 16),
                    ),
                    if (habit.description != null &&
                        habit.description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(habit.description!, style: AppTypography.bodySmall),
                    ],
                  ],
                ),
              ),

              // Delete button
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: AppColors.secondaryText,
                ),
                onPressed: () => _confirmDelete(context, habit),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceM),

          // Streak Info & Completion Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Streaks info
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: currentStreak > 0
                          ? AppColors.badgeBackground
                          : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusFull,
                      ),
                      border: Border.all(
                        color: currentStreak > 0
                            ? AppColors.lightGreenAccent
                            : AppColors.subtleBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          size: 14,
                          color: Color(0xFFE65100),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$currentStreak day streak',
                          style: AppTypography.badgeText.copyWith(
                            color: currentStreak > 0
                                ? AppColors.badgeText
                                : AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (longestStreak > 0) ...[
                    const SizedBox(width: AppDimensions.spaceS),
                    Text(
                      'Best: $longestStreak',
                      style: AppTypography.bodySmall.copyWith(fontSize: 11),
                    ),
                  ],
                ],
              ),

              // One-Tap Toggle Button for Today
              ElevatedButton.icon(
                onPressed: () => controller.toggleCompletion(habit.id),
                icon: Icon(
                  isCompletedToday
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  size: 16,
                  color: isCompletedToday
                      ? AppColors.lightGreenAccent
                      : AppColors.lightText,
                ),
                label: Text(
                  isCompletedToday ? 'Completed' : 'Mark Done',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.lightText,
                    fontSize: 12,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompletedToday
                      ? AppColors.primaryForestGreen
                      : AppColors.darkForestHover,
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusFull,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
