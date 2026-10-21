import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/empty_state_card.dart';
import '../../../data/models/goal.dart';
import '../../../logic/app_state.dart';
import 'widgets/create_goal_sheet.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  int _selectedFilterIndex = 0; // 0: Active, 1: Completed

  void _openCreateSheet(BuildContext context, {Goal? existingGoal}) {
    final appState = AppStateScope.of(context);
    CreateGoalSheet.show(
      context: context,
      existingGoal: existingGoal,
      onSave:
          ({
            required String title,
            String? description,
            DateTime? targetDate,
            required bool isDailyPriority,
          }) async {
            if (existingGoal != null) {
              return await appState.goalsController.updateGoal(
                existingGoal.copyWith(
                  title: title,
                  description: description,
                  targetDate: targetDate,
                  isDailyPriority: isDailyPriority,
                  clearDescription: description == null || description.isEmpty,
                  clearTargetDate: targetDate == null,
                ),
              );
            } else {
              return await appState.goalsController.createGoal(
                title: title,
                description: description,
                targetDate: targetDate,
                isDailyPriority: isDailyPriority,
              );
            }
          },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Goal goal) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete Goal?',
      message:
          'Are you sure you want to delete "${goal.title}"? This cannot be undone.',
      confirmLabel: 'Delete',
    );
    if (confirmed && context.mounted) {
      final appState = AppStateScope.of(context);
      await appState.goalsController.deleteGoal(goal.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final controller = appState.goalsController;

    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final allGoals = controller.goals;
            final activeGoals = allGoals.where((g) => !g.isCompleted).toList();
            final completedGoals = allGoals
                .where((g) => g.isCompleted)
                .toList();
            final displayedGoals = _selectedFilterIndex == 0
                ? activeGoals
                : completedGoals;

            final activePrioritiesCount = controller.dailyPriorities
                .where((g) => !g.isCompleted)
                .length;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPaddingH,
                vertical: AppDimensions.screenPaddingV,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header & Action Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Goals', style: AppTypography.displayLarge),
                          const SizedBox(height: 2),
                          Text(
                            'Focus on what moves your life forward.',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                      AppButton(
                        label: 'New Goal',
                        icon: Icons.add,
                        isFullWidth: false,
                        onPressed: () => _openCreateSheet(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spaceL),

                  // Daily Priorities Indicator Card
                  AppCard(
                    backgroundColor: AppColors.accentSurface,
                    borderColor: AppColors.lightGreenAccent.withValues(
                      alpha: 0.6,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: AppColors.primaryForestGreen,
                              size: 22,
                            ),
                            const SizedBox(width: AppDimensions.spaceS),
                            Text(
                              "Today's Active Priorities",
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.primaryForestGreen,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spaceS + 2,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.badgeBackground,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusFull,
                            ),
                          ),
                          child: Text(
                            '$activePrioritiesCount/3 Active',
                            style: AppTypography.badgeText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceL),

                  // Segmented Tabs: Active vs Completed
                  Row(
                    children: [
                      _buildTabChip('Active (${activeGoals.length})', 0),
                      const SizedBox(width: AppDimensions.spaceS),
                      _buildTabChip('Completed (${completedGoals.length})', 1),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spaceM),

                  // Error Banner if any
                  if (controller.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.spaceM),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 18,
                            color: Color(0xFFC62828),
                          ),
                          const SizedBox(width: AppDimensions.spaceS),
                          Expanded(
                            child: Text(
                              controller.errorMessage!,
                              style: AppTypography.bodySmall.copyWith(
                                color: const Color(0xFFC62828),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceM),
                  ],

                  // Goals List or Empty State
                  if (displayedGoals.isEmpty)
                    EmptyStateCard(
                      icon: _selectedFilterIndex == 0
                          ? Icons.track_changes_outlined
                          : Icons.check_circle_outline,
                      title: _selectedFilterIndex == 0
                          ? 'No Active Goals'
                          : 'No Completed Goals Yet',
                      description: _selectedFilterIndex == 0
                          ? 'Add high-impact daily priorities or longer-term milestones by tapping "New Goal".'
                          : 'Goals you complete will appear here as your track record of progress.',
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayedGoals.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppDimensions.spaceM),
                      itemBuilder: (context, index) {
                        final goal = displayedGoals[index];
                        return _buildGoalItem(context, goal);
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

  Widget _buildTabChip(String label, int index) {
    final isSelected = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilterIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceM,
          vertical: AppDimensions.spaceS,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryForestGreen
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryForestGreen
                : AppColors.subtleBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelLarge.copyWith(
            color: isSelected ? AppColors.lightText : AppColors.secondaryText,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildGoalItem(BuildContext context, Goal goal) {
    final appState = AppStateScope.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox Toggle
              GestureDetector(
                onTap: () => appState.goalsController.toggleGoal(goal.id),
                child: Container(
                  width: 26,
                  height: 26,
                  margin: const EdgeInsets.only(top: 2),
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
                          size: 16,
                          color: AppColors.lightText,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: AppDimensions.spaceM),

              // Title and Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: AppTypography.headlineSmall.copyWith(
                        fontSize: 16,
                        decoration: goal.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: goal.isCompleted
                            ? AppColors.secondaryText
                            : AppColors.primaryText,
                      ),
                    ),
                    if (goal.description != null &&
                        goal.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(goal.description!, style: AppTypography.bodySmall),
                    ],
                  ],
                ),
              ),

              // Edit / Delete Popup Menu
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  size: 20,
                  color: AppColors.secondaryText,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                onSelected: (val) {
                  if (val == 'edit') {
                    _openCreateSheet(context, existingGoal: goal);
                  } else if (val == 'delete') {
                    _confirmDelete(context, goal);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Delete',
                      style: TextStyle(color: Color(0xFFBA1A1A)),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Badges Row
          if (goal.isDailyPriority || goal.targetDate != null) ...[
            const SizedBox(height: AppDimensions.spaceM),
            Wrap(
              spacing: AppDimensions.spaceS,
              runSpacing: AppDimensions.spaceXS,
              children: [
                if (goal.isDailyPriority)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.badgeBackground,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusFull,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: AppColors.badgeText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Today's Priority",
                          style: AppTypography.badgeText,
                        ),
                      ],
                    ),
                  ),
                if (goal.targetDate != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: goal.isOverdue
                          ? const Color(0xFFFFEBEE)
                          : AppColors.cardBackground,
                      border: Border.all(
                        color: goal.isOverdue
                            ? const Color(0xFFEF9A9A)
                            : AppColors.subtleBorder,
                      ),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusFull,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 13,
                          color: goal.isOverdue
                              ? const Color(0xFFC62828)
                              : AppColors.secondaryText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          goal.isOverdue
                              ? 'Overdue (${AppDateUtils.formatDisplayDate(goal.targetDate!)})'
                              : AppDateUtils.formatDisplayDate(
                                  goal.targetDate!,
                                ),
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: goal.isOverdue
                                ? const Color(0xFFC62828)
                                : AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
