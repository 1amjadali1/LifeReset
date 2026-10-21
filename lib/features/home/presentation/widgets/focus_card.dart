import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';
import '../../../../app/app_typography.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../logic/focus_timer_controller.dart';

/// Prominent focus card on Home reflecting the real active timer state.
class FocusCard extends StatelessWidget {
  const FocusCard({
    super.key,
    required this.controller,
    required this.onNavigateToFocus,
  });

  final FocusTimerController controller;
  final VoidCallback onNavigateToFocus;

  @override
  Widget build(BuildContext context) {
    final isRunning = controller.isRunning;
    final isPaused = controller.isPaused;
    final isCompleted = controller.isCompleted;

    String statusBadge;
    String title;
    String subtitle;
    String buttonLabel;

    if (isRunning) {
      statusBadge = 'Running (${controller.formattedRemainingTime})';
      title = 'Deep Focus Active';
      subtitle = 'Stay present. Your timer is tracking accurately.';
      buttonLabel = 'Open Focus Screen';
    } else if (isPaused) {
      statusBadge = 'Paused (${controller.formattedRemainingTime})';
      title = 'Session Paused';
      subtitle = 'Take a breath. Resume whenever you are ready.';
      buttonLabel = 'Resume Session';
    } else if (isCompleted) {
      statusBadge = 'Completed!';
      title = 'Focus Goal Reached';
      subtitle =
          '+${controller.targetDurationMinutes} mins added to your daily progress.';
      buttonLabel = 'Start Another Session';
    } else {
      statusBadge = '${controller.targetDurationMinutes}m Preset';
      title = 'Deep Focus Session';
      subtitle = 'Reclaim your attention and get into the flow zone.';
      buttonLabel = 'Start ${controller.targetDurationMinutes}m Focus';
    }

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceL),
      decoration: BoxDecoration(
        color: AppColors.primaryForestGreen,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryForestGreen.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Status badge + Timer icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceS + 4,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightGreenAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  border: Border.all(
                    color: AppColors.lightGreenAccent.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.lightGreenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusBadge,
                      style: AppTypography.badgeText.copyWith(
                        color: AppColors.lightGreenAccent,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.timer_outlined,
                color: AppColors.lightGreenAccent,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceM),

          // Title
          Text(
            title,
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.lightText,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceXS),

          // Subtitle
          Text(
            subtitle,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.lightGreenAccent.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceL),

          // Action button
          AppButton(
            label: buttonLabel,
            icon: isRunning
                ? Icons.fullscreen_rounded
                : Icons.play_arrow_rounded,
            variant: AppButtonVariant.accent,
            onPressed: onNavigateToFocus,
          ),
        ],
      ),
    );
  }
}
