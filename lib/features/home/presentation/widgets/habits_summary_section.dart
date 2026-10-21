import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';
import '../../../../app/app_typography.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state_card.dart';
import '../../../../logic/habits_controller.dart';

/// Section showing real daily habits on Home with quick completion.
class HabitsSummarySection extends StatelessWidget {
  const HabitsSummarySection({
    super.key,
    required this.controller,
    required this.onNavigateToHabits,
  });

  final HabitsController controller;
  final VoidCallback onNavigateToHabits;

  @override
  Widget build(BuildContext context) {
    final habits = controller.habits;
    final completedCount = controller.completedTodayCount;
    final totalCount = controller.totalActiveCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text('Daily Habits', style: AppTypography.headlineSmall),
                if (totalCount > 0) ...[
                  const SizedBox(width: AppDimensions.spaceS),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.badgeBackground,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusFull,
                      ),
                    ),
                    child: Text(
                      '$completedCount/$totalCount',
                      style: AppTypography.badgeText,
                    ),
                  ),
                ],
              ],
            ),
            GestureDetector(
              onTap: onNavigateToHabits,
              child: Text(
                'View All',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primaryForestGreen,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spaceM),

        if (habits.isEmpty)
          const EmptyStateCard(
            icon: Icons.repeat_rounded,
            title: 'No Habits Tracked Yet',
            description: 'Start small with 1 or 2 positive daily routines in the Habits tab.',
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: habits.take(3).length, // Show top 3 on home
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppDimensions.spaceS),
            itemBuilder: (context, index) {
              final habit = habits[index];
              final isCompleted = controller.completedTodayIds.contains(
                habit.id,
              );
              final streak = controller.getStreak(habit.id);
              final streakCount = streak?.currentStreak ?? 0;

              final iconData = AppIcons.getHabitIcon(habit.iconCodePoint);

              return AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.badgeBackground
                            : AppColors.accentSurface,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusS,
                        ),
                      ),
                      child: Icon(
                        iconData,
                        size: 16,
                        color: AppColors.primaryForestGreen,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spaceM),
                    Expanded(
                      child: Text(
                        habit.name,
                        style: AppTypography.bodyMedium.copyWith(
                          fontSize: 15,
                          color: isCompleted
                              ? AppColors.secondaryText
                              : AppColors.primaryText,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    if (streakCount > 0) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            size: 14,
                            color: Color(0xFFE65100),
                          ),
                          Text(
                            '$streakCount',
                            style: AppTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFE65100),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ],
                    GestureDetector(
                      onTap: () => controller.toggleCompletion(habit.id),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppColors.primaryForestGreen
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCompleted
                                ? AppColors.primaryForestGreen
                                : AppColors.secondaryText,
                            width: 1.5,
                          ),
                        ),
                        child: isCompleted
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: AppColors.lightText,
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
