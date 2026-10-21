import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../logic/app_state.dart';
import '../../../logic/focus_timer_controller.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  static const List<int> _presetDurations = [15, 25, 45, 60];

  Future<void> _confirmCancel(
    BuildContext context,
    FocusTimerController controller,
  ) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Cancel Focus Session?',
      message:
          'Stopping now will cancel this session without recording focus time.',
      confirmLabel: 'End Session',
      cancelLabel: 'Keep Going',
    );
    if (confirmed) {
      controller.cancelTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final controller = appState.focusTimerController;
    final goals = appState.goalsController.goals
        .where((g) => !g.isCompleted)
        .toList();

    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final isRunning = controller.isRunning;
            final isPaused = controller.isPaused;
            final isCompleted = controller.isCompleted;
            final isIdle = controller.isIdle;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPaddingH,
                vertical: AppDimensions.screenPaddingV,
              ),
              child: Column(
                children: [
                  // Top Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Focus Timer',
                            style: AppTypography.displayLarge,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Put down the phone and enter flow.',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.badgeBackground,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusFull,
                          ),
                        ),
                        child: Text(
                          isRunning
                              ? 'In Progress'
                              : (isPaused
                                    ? 'Paused'
                                    : (isCompleted ? 'Completed' : 'Ready')),
                          style: AppTypography.badgeText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spaceXL),

                  // Circular Timer Display
                  Center(
                    child: SizedBox(
                      width: 250,
                      height: 250,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background Ring
                          SizedBox(
                            width: 250,
                            height: 250,
                            child: CircularProgressIndicator(
                              value: 1.0,
                              strokeWidth: 10,
                              color: AppColors.accentSurface,
                            ),
                          ),
                          // Active Progress Ring
                          SizedBox(
                            width: 250,
                            height: 250,
                            child: CircularProgressIndicator(
                              value: controller.progressFraction,
                              strokeWidth: 10,
                              strokeCap: StrokeCap.round,
                              color: AppColors.primaryForestGreen,
                            ),
                          ),
                          // Center Countdown & Labels
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                controller.formattedRemainingTime,
                                style: AppTypography.displayLarge.copyWith(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isCompleted
                                    ? 'Session Complete!'
                                    : (isRunning
                                          ? 'Remaining'
                                          : (isPaused
                                                ? 'Paused'
                                                : '${controller.targetDurationMinutes} min target')),
                                style: AppTypography.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isCompleted
                                      ? AppColors.primaryForestGreen
                                      : AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceXL),

                  // Duration Presets (Only visible when idle)
                  if (isIdle) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _presetDurations.map((duration) {
                        final isSelected =
                            controller.targetDurationMinutes == duration;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text('${duration}m'),
                            selected: isSelected,
                            selectedColor: AppColors.primaryForestGreen,
                            backgroundColor: AppColors.cardBackground,
                            labelStyle: AppTypography.labelLarge.copyWith(
                              color: isSelected
                                  ? AppColors.lightText
                                  : AppColors.primaryText,
                              fontSize: 13,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primaryForestGreen
                                  : AppColors.subtleBorder,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusFull,
                              ),
                            ),
                            onSelected: (_) =>
                                controller.setDurationMinutes(duration),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppDimensions.spaceL),

                    // Linked Goal Selector (Optional)
                    if (goals.isNotEmpty)
                      AppCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            isExpanded: true,
                            value: controller.linkedGoalId,
                            hint: Text(
                              'Link to an active goal (Optional)',
                              style: AppTypography.bodySmall,
                            ),
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: AppColors.secondaryText,
                            ),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('No goal linked (General focus)'),
                              ),
                              ...goals.map((goal) {
                                return DropdownMenuItem<String?>(
                                  value: goal.id,
                                  child: Text(
                                    goal.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }),
                            ],
                            onChanged: (val) => controller.setLinkedGoal(val),
                          ),
                        ),
                      ),
                    const SizedBox(height: AppDimensions.spaceL),
                  ],

                  // Action Buttons based on status
                  if (isIdle)
                    AppButton(
                      label: 'Start Focus Session',
                      icon: Icons.play_arrow_rounded,
                      onPressed: controller.startTimer,
                    ),

                  if (isRunning)
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'Pause',
                            icon: Icons.pause_rounded,
                            variant: AppButtonVariant.secondary,
                            onPressed: controller.pauseTimer,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spaceM),
                        Expanded(
                          child: AppButton(
                            label: 'Cancel',
                            icon: Icons.close_rounded,
                            variant: AppButtonVariant.primary,
                            onPressed: () =>
                                _confirmCancel(context, controller),
                          ),
                        ),
                      ],
                    ),

                  if (isPaused)
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'Resume',
                            icon: Icons.play_arrow_rounded,
                            variant: AppButtonVariant.primary,
                            onPressed: controller.resumeTimer,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spaceM),
                        Expanded(
                          child: AppButton(
                            label: 'Cancel',
                            icon: Icons.close_rounded,
                            variant: AppButtonVariant.secondary,
                            onPressed: () =>
                                _confirmCancel(context, controller),
                          ),
                        ),
                      ],
                    ),

                  if (isCompleted) ...[
                    AppCard(
                      backgroundColor: AppColors.accentSurface,
                      borderColor: AppColors.lightGreenAccent,
                      child: Column(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primaryForestGreen,
                            size: 36,
                          ),
                          const SizedBox(height: AppDimensions.spaceS),
                          Text(
                            'Session Complete!',
                            style: AppTypography.headlineSmall.copyWith(
                              color: AppColors.primaryForestGreen,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '+${controller.targetDurationMinutes} minutes of mindful focus recorded locally.',
                            style: AppTypography.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceM),
                    AppButton(
                      label: 'Start Another Session',
                      icon: Icons.refresh_rounded,
                      onPressed: controller.resetAfterCompletion,
                    ),
                  ],

                  const SizedBox(height: AppDimensions.spaceXL),

                  // Today's Focus Overview Footer Card
                  AppCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              '${controller.totalFocusMinutesToday}m',
                              style: AppTypography.headlineMedium.copyWith(
                                color: AppColors.primaryForestGreen,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Today's Focus Time",
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: AppColors.subtleBorder,
                        ),
                        Column(
                          children: [
                            Text(
                              '${controller.totalCompletedSessionsToday}',
                              style: AppTypography.headlineMedium.copyWith(
                                color: AppColors.primaryForestGreen,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Sessions Completed',
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
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
}
