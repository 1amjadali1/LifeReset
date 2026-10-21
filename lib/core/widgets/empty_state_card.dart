import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../app/app_typography.dart';
import '../constants/app_dimensions.dart';
import 'app_card.dart';

/// An elegant, honest empty-state card for features with no data or upcoming functionality.
class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.statusBadge,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? statusBadge;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.spaceL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accentSurface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: AppColors.primaryForestGreen,
                ),
              ),
              const SizedBox(width: AppDimensions.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.headlineSmall.copyWith(fontSize: 16),
                    ),
                    if (statusBadge != null) ...[
                      const SizedBox(height: AppDimensions.spaceXS),
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
                          statusBadge!,
                          style: AppTypography.badgeText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceM),
          Text(description, style: AppTypography.bodyMedium),
        ],
      ),
    );
  }
}
