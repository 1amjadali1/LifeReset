import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';
import '../../../../app/app_typography.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../logic/social_media_controller.dart';
import '../../../progress/presentation/widgets/log_social_media_sheet.dart';

/// Clean glance card on Home showing today's social media time vs target limit.
class SocialMediaGlanceCard extends StatelessWidget {
  const SocialMediaGlanceCard({
    super.key,
    required this.controller,
    required this.onNavigateToProgress,
  });

  final SocialMediaController controller;
  final VoidCallback onNavigateToProgress;

  void _openLogSheet(BuildContext context) {
    LogSocialMediaSheet.show(
      context: context,
      onSave:
          ({
            required String appName,
            required int durationMinutes,
            String? notes,
          }) async {
            return await controller.addEntry(
              appName: appName,
              durationMinutes: durationMinutes,
              notes: notes,
            );
          },
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayTotal = controller.todayTotalMinutes;
    final limit = controller.dailyLimitMinutes;
    final isExceeded = controller.isLimitExceeded;

    return AppCard(
      borderColor: isExceeded
          ? const Color(0xFFEF9A9A)
          : AppColors.subtleBorder,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isExceeded
                      ? const Color(0xFFFFEBEE)
                      : AppColors.accentSurface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Icon(
                  Icons.smartphone_rounded,
                  size: 20,
                  color: isExceeded
                      ? const Color(0xFFC62828)
                      : AppColors.primaryForestGreen,
                ),
              ),
              const SizedBox(width: AppDimensions.spaceM),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Scrolling Time",
                    style: AppTypography.labelLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    todayTotal == 0
                        ? 'No time recorded yet'
                        : '$todayTotal mins of $limit min goal',
                    style: AppTypography.bodySmall.copyWith(
                      color: isExceeded
                          ? const Color(0xFFC62828)
                          : AppColors.secondaryText,
                      fontWeight: isExceeded
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          OutlinedButton(
            onPressed: () => _openLogSheet(context),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 32),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            ),
            child: Text('+ Log', style: AppTypography.badgeText),
          ),
        ],
      ),
    );
  }
}
