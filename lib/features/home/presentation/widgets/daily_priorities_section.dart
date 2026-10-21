import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';
import '../../../../app/app_typography.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state_card.dart';
import '../../../../logic/goals_controller.dart';

/// Section showing real daily priorities on Home with one-tap completion.
class DailyPrioritiesSection extends StatelessWidget {
  const DailyPrioritiesSection({
    super.key,
    required this.controller,
    required this.onNavigateToGoals,
  });

  final GoalsController controller;
  final VoidCallback onNavigateToGoals;

  @override
  Widget build(BuildContext context) {
    final priorities = controller.dailyPriorities;
    final completedCount = priorities.where((g) => g.isCompleted).length;
    final totalCount = priorities.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text("Today's Priorities", style: AppTypography.headlineSmall),
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
              onTap: onNavigateToGoals,
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

        if (priorities.isEmpty)
          const EmptyStateCard(
            icon: Icons.track_changes_rounded,
            title: 'No Priorities Set for Today',
            description: 'Choose up to 3 high-impact goals in the Goals tab to keep your daily focus sharp.',
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: priorities.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppDimensions.spaceS),
            itemBuilder: (context, index) {
              final goal = priorities[index];
              return AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => controller.toggleGoal(goal.id),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: goal.isCompleted
                              ? AppColors.primaryForestGreen
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: goal.isCompleted
                                ? AppColors.primaryForestGreen
                                : AppColors.secondaryText,
                            width: 1.5,
                          ),
                        ),
                        child: goal.isCompleted
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: AppColors.lightText,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spaceM),
                    Expanded(
                      child: Text(
                        goal.title,
                        style: AppTypography.bodyMedium.copyWith(
                          fontSize: 15,
                          color: goal.isCompleted
                              ? AppColors.secondaryText
                              : AppColors.primaryText,
                          decoration: goal.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
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
