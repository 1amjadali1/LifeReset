import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';
import '../../../../app/app_typography.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../settings/presentation/settings_screen.dart';

/// Header widget displaying the current greeting, app identity, date, and settings button.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return AppStrings.greetingMorning;
    } else if (hour < 17) {
      return AppStrings.greetingAfternoon;
    } else {
      return AppStrings.greetingEvening;
    }
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final weekday = weekdays[now.weekday - 1];
    final month = months[now.month - 1];
    return '$weekday, ${now.day} $month';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date and Settings / Tagline row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getFormattedDate(),
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryText,
                letterSpacing: 0.3,
              ),
            ),
            Row(
              children: [
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
                    border: Border.all(
                      color: AppColors.lightGreenAccent.withValues(alpha: 0.8),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    AppStrings.tagline,
                    style: AppTypography.badgeText,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceS),
                IconButton(
                  icon: const Icon(
                    Icons.settings_outlined,
                    size: 20,
                    color: AppColors.primaryForestGreen,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => SettingsScreen.navigate(context),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spaceS),

        // Greeting
        Text(
          _getGreeting(),
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.secondaryText,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 2),

        // App Title
        Text(AppStrings.appName, style: AppTypography.displayLarge),
      ],
    );
  }
}
