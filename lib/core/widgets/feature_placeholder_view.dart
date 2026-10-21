import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../app/app_typography.dart';
import '../constants/app_dimensions.dart';
import 'app_card.dart';

/// Reusable view for tabs that are planned for subsequent milestones.
/// Provides a clear, non-deceptive overview of upcoming functionality.
class FeaturePlaceholderView extends StatelessWidget {
  const FeaturePlaceholderView({
    super.key,
    required this.title,
    required this.subtitle,
    required this.milestoneTag,
    required this.icon,
    required this.plannedCapabilities,
  });

  final String title;
  final String subtitle;
  final String milestoneTag;
  final IconData icon;
  final List<String> plannedCapabilities;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.screenPaddingH,
          vertical: AppDimensions.screenPaddingV,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryForestGreen,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.lightGreenAccent,
                    size: 26,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.displayLarge.copyWith(
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spaceS,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.badgeBackground,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusS,
                          ),
                        ),
                        child: Text(
                          milestoneTag,
                          style: AppTypography.badgeText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceM),
            Text(subtitle, style: AppTypography.bodyMedium),
            const SizedBox(height: AppDimensions.spaceL),

            // Planned capabilities card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Planned Capabilities',
                    style: AppTypography.headlineSmall.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: AppDimensions.spaceM),
                  ...plannedCapabilities.map((capability) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppDimensions.spaceS,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Icon(
                              Icons.check_circle_outline,
                              size: 16,
                              color: AppColors.primaryForestGreen,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spaceS),
                          Expanded(
                            child: Text(
                              capability,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.primaryText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spaceL),

            // Note card
            AppCard(
              backgroundColor: AppColors.accentSurface,
              borderColor: AppColors.lightGreenAccent.withValues(alpha: 0.5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 20,
                    color: AppColors.primaryForestGreen,
                  ),
                  const SizedBox(width: AppDimensions.spaceM),
                  Expanded(
                    child: Text(
                      'No fake progress or placeholder timers are displayed. This section will activate cleanly when its dedicated milestone is built.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primaryForestGreen,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
