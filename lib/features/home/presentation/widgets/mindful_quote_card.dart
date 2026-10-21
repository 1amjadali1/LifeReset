import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';
import '../../../../app/app_typography.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/app_card.dart';

/// A calming, non-judgmental wellness note on the home screen.
class MindfulQuoteCard extends StatelessWidget {
  const MindfulQuoteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.accentSurface,
      borderColor: AppColors.lightGreenAccent.withValues(alpha: 0.6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.spaceS),
            decoration: BoxDecoration(
              color: AppColors.badgeBackground,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: const Icon(
              Icons.spa_outlined,
              size: 20,
              color: AppColors.primaryForestGreen,
            ),
          ),
          const SizedBox(width: AppDimensions.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scroll Se Goal Tak',
                  style: AppTypography.headlineSmall.copyWith(
                    fontSize: 15,
                    color: AppColors.primaryForestGreen,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Every conscious choice to pause scrolling gives you time back for what truly matters.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primaryForestGreen.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
