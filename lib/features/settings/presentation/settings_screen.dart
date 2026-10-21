import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../logic/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static Future<void> navigate(BuildContext context) {
    return Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
  }

  Future<void> _changeSocialMediaLimit(BuildContext context) async {
    final appState = AppStateScope.of(context);
    final currentLimit = appState.socialMediaController.dailyLimitMinutes;
    final controller = TextEditingController(text: currentLimit.toString());

    final newLimit = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: Text(
          'Daily Scrolling Limit',
          style: AppTypography.headlineSmall,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set your ideal maximum daily social media time in minutes.',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppDimensions.spaceM),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                suffixText: 'mins',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text.trim());
              if (val != null && val > 0) {
                Navigator.of(ctx).pop(val);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newLimit != null && context.mounted) {
      await appState.socialMediaController.updateLimit(newLimit);
    }
  }

  Future<void> _exportData(BuildContext context) async {
    final appState = AppStateScope.of(context);
    final jsonString = await appState.settingsRepository.exportDataAsJson();

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXL),
        ),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Exported Data (JSON)',
                  style: AppTypography.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceS),
            Text(
              'Your entire activity log formatted as standard JSON.',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppDimensions.spaceM),
            Container(
              height: 250,
              padding: const EdgeInsets.all(AppDimensions.spaceM),
              decoration: BoxDecoration(
                color: AppColors.appBackground,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: Border.all(color: AppColors.subtleBorder),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  jsonString,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spaceM),
            AppButton(
              label: 'Copy to Clipboard',
              icon: Icons.copy_rounded,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: jsonString));
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data copied to clipboard!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAll(BuildContext context) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Reset All App Data?',
      message: 'This will permanently erase all goals, habit streaks, focus records, and social media logs. This action cannot be undone.',
      confirmLabel: 'Erase Everything',
    );

    if (confirmed && context.mounted) {
      final doubleConfirmed = await ConfirmationDialog.show(
        context: context,
        title: 'Final Confirmation',
        message: 'Are you completely sure? All your progress data will be reset to fresh defaults.',
        confirmLabel: 'Confirm Reset',
      );

      if (doubleConfirmed && context.mounted) {
        final appState = AppStateScope.of(context);
        await appState.deleteAllData();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All data has been reset.')),
          );
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Privacy')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingH,
            vertical: AppDimensions.screenPaddingV,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Identity Card
              AppCard(
                backgroundColor: AppColors.accentSurface,
                borderColor: AppColors.lightGreenAccent.withValues(alpha: 0.6),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryForestGreen,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM,
                        ),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
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
                            'Life Reset v1.0.0',
                            style: AppTypography.headlineSmall.copyWith(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '100% Offline & Private',
                            style: AppTypography.badgeText,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'All goals, habits, and focus sessions are stored strictly on your device. Zero servers, zero tracking.',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spaceL),

              // Preferences Section
              Text('Preferences', style: AppTypography.headlineSmall),
              const SizedBox(height: AppDimensions.spaceM),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.timer_outlined,
                        color: AppColors.primaryForestGreen,
                      ),
                      title: Text(
                        'Daily Scrolling Target',
                        style: AppTypography.labelLarge,
                      ),
                      subtitle: Text(
                        'Currently set to ${appState.socialMediaController.dailyLimitMinutes} mins',
                        style: AppTypography.bodySmall,
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: AppColors.secondaryText,
                      ),
                      onTap: () => _changeSocialMediaLimit(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spaceL),

              // Backup & Export Section
              Text('Data & Backup', style: AppTypography.headlineSmall),
              const SizedBox(height: AppDimensions.spaceM),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.file_download_outlined,
                        color: AppColors.primaryForestGreen,
                      ),
                      title: Text(
                        'Export All Data (JSON)',
                        style: AppTypography.labelLarge,
                      ),
                      subtitle: Text(
                        'Create a portable text backup of your local records.',
                        style: AppTypography.bodySmall,
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: AppColors.secondaryText,
                      ),
                      onTap: () => _exportData(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spaceL),

              // Danger Zone
              Text(
                'Reset & Clear',
                style: AppTypography.headlineSmall.copyWith(
                  color: const Color(0xFFBA1A1A),
                ),
              ),
              const SizedBox(height: AppDimensions.spaceM),
              AppCard(
                borderColor: const Color(0xFFFFCDD2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Clear Local Database',
                      style: AppTypography.labelLarge.copyWith(
                        color: const Color(0xFFBA1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Permanently remove all goals, streaks, focus logs, and screen-time entries from this device.',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: AppDimensions.spaceM),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFBA1A1A),
                        side: const BorderSide(color: Color(0xFFBA1A1A)),
                      ),
                      onPressed: () => _confirmDeleteAll(context),
                      child: const Text('Delete All App Data'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
