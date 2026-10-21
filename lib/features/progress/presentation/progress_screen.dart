import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state_card.dart';
import '../../../data/models/social_media_entry.dart';
import '../../../logic/app_state.dart';
import '../../settings/presentation/settings_screen.dart';
import 'widgets/log_social_media_sheet.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  void _openLogSheet(BuildContext context) {
    final appState = AppStateScope.of(context);
    LogSocialMediaSheet.show(
      context: context,
      onSave:
          ({
            required String appName,
            required int durationMinutes,
            String? notes,
          }) async {
            final success = await appState.socialMediaController.addEntry(
              appName: appName,
              durationMinutes: durationMinutes,
              notes: notes,
            );
            if (success) {
              await appState.progressController.loadWeeklyReport();
            }
            return success;
          },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final progressController = appState.progressController;
    final socialMediaController = appState.socialMediaController;

    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([
            progressController,
            socialMediaController,
          ]),
          builder: (context, _) {
            final report = progressController.report;
            final todayEntries = socialMediaController.todayEntries;
            final todayTotalMins = socialMediaController.todayTotalMinutes;
            final dailyLimit = socialMediaController.dailyLimitMinutes;
            final isExceeded = socialMediaController.isLimitExceeded;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPaddingH,
                vertical: AppDimensions.screenPaddingV,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row with Settings Shortcut
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Progress', style: AppTypography.displayLarge),
                          const SizedBox(height: 2),
                          Text(
                            'Real metrics from your real routines.',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.settings_outlined,
                          color: AppColors.primaryForestGreen,
                        ),
                        onPressed: () => SettingsScreen.navigate(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spaceL),

                  // Today's Social Media Awareness Card
                  _buildSocialMediaCard(
                    context: context,
                    todayTotalMins: todayTotalMins,
                    dailyLimit: dailyLimit,
                    isExceeded: isExceeded,
                    todayEntries: todayEntries,
                    onDeleteEntry: (id) async {
                      await socialMediaController.deleteEntry(id);
                      await progressController.loadWeeklyReport();
                    },
                  ),
                  const SizedBox(height: AppDimensions.spaceL),

                  // 7-Day Summary Section
                  Text('Weekly Snapshot', style: AppTypography.headlineSmall),
                  const SizedBox(height: AppDimensions.spaceM),

                  if (report == null || !report.hasAnyData)
                    const EmptyStateCard(
                      icon: Icons.insights_rounded,
                      title: 'No Weekly Activity Recorded',
                      description: 'Complete focus sessions, goals, habits, or log scrolling time to generate meaningful weekly insights.',
                    )
                  else ...[
                    // Metrics Grid (2x2)
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricTile(
                            label: 'Focus Time',
                            value: '${report.totalFocusMinutes}m',
                            icon: Icons.timer_outlined,
                            subtitle: 'Past 7 days',
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spaceM),
                        Expanded(
                          child: _buildMetricTile(
                            label: 'Logged Scrolling',
                            value: '${report.totalSocialMediaMinutes}m',
                            icon: Icons.smartphone_rounded,
                            subtitle: 'Past 7 days',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spaceM),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricTile(
                            label: 'Habits Completed',
                            value: '${report.totalHabitCompletions}',
                            icon: Icons.repeat_rounded,
                            subtitle:
                                'Consistency: ${(report.habitConsistencyRate * 100).round()}%',
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spaceM),
                        Expanded(
                          child: _buildMetricTile(
                            label: 'Goals Completed',
                            value: '${report.totalGoalsCompleted}',
                            icon: Icons.check_circle_outline,
                            subtitle: 'All-time active',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spaceL),

                    // Daily breakdown table
                    Text(
                      '7-Day Daily Breakdown',
                      style: AppTypography.labelLarge,
                    ),
                    const SizedBox(height: AppDimensions.spaceS),
                    AppCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        children: report.dailyMetrics.map((day) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 44,
                                  child: Text(
                                    day.dayLabel,
                                    style: AppTypography.labelLarge.copyWith(
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.timer_outlined,
                                      size: 14,
                                      color: AppColors.primaryForestGreen,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${day.focusMinutes}m focus',
                                      style: AppTypography.bodySmall,
                                    ),
                                    const SizedBox(width: 14),
                                    const Icon(
                                      Icons.smartphone_rounded,
                                      size: 14,
                                      color: Color(0xFFE65100),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${day.socialMediaMinutes}m social',
                                      style: AppTypography.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppDimensions.spaceXXL),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required String subtitle,
  }) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTypography.bodySmall),
              Icon(icon, size: 18, color: AppColors.primaryForestGreen),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceS),
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.primaryForestGreen,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildSocialMediaCard({
    required BuildContext context,
    required int todayTotalMins,
    required int dailyLimit,
    required bool isExceeded,
    required List<SocialMediaEntry> todayEntries,
    required Future<void> Function(String id) onDeleteEntry,
  }) {
    return AppCard(
      borderColor: isExceeded
          ? const Color(0xFFEF9A9A)
          : AppColors.subtleBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isExceeded
                          ? const Color(0xFFFFEBEE)
                          : AppColors.accentSurface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.timer_outlined,
                      size: 18,
                      color: isExceeded
                          ? const Color(0xFFC62828)
                          : AppColors.primaryForestGreen,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceS),
                  Text(
                    "Today's Scrolling Time",
                    style: AppTypography.labelLarge,
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () => _openLogSheet(context),
                icon: const Icon(Icons.add, size: 14),
                label: const Text('Log Time'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 32),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  textStyle: AppTypography.badgeText,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceM),

          // Time Comparison
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${todayTotalMins}m',
                style: AppTypography.headlineMedium.copyWith(
                  color: isExceeded
                      ? const Color(0xFFBA1A1A)
                      : AppColors.primaryForestGreen,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Text('/ $dailyLimit min limit', style: AppTypography.bodyMedium),
            ],
          ),

          if (isExceeded) ...[
            const SizedBox(height: AppDimensions.spaceS),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: Color(0xFFC62828),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Daily target exceeded by ${todayTotalMins - dailyLimit} mins. A great time to reset and focus!',
                      style: AppTypography.bodySmall.copyWith(
                        color: const Color(0xFFC62828),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (todayEntries.isNotEmpty) ...[
            const Divider(height: 24),
            Text(
              'Logged Today',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceS),
            ...todayEntries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.appName, style: AppTypography.bodyMedium),
                    Row(
                      children: [
                        Text(
                          '${entry.durationMinutes} mins',
                          style: AppTypography.bodySmall,
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => onDeleteEntry(entry.id),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
