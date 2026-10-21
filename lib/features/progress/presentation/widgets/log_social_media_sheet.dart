import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';
import '../../../../app/app_typography.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';

class LogSocialMediaSheet extends StatefulWidget {
  const LogSocialMediaSheet({super.key, required this.onSave});

  final Future<bool> Function({
    required String appName,
    required int durationMinutes,
    String? notes,
  })
  onSave;

  static Future<void> show({
    required BuildContext context,
    required Future<bool> Function({
      required String appName,
      required int durationMinutes,
      String? notes,
    })
    onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXL),
        ),
      ),
      builder: (ctx) => LogSocialMediaSheet(onSave: onSave),
    );
  }

  @override
  State<LogSocialMediaSheet> createState() => _LogSocialMediaSheetState();
}

class _LogSocialMediaSheetState extends State<LogSocialMediaSheet> {
  static const List<String> _popularApps = [
    'Instagram',
    'YouTube',
    'X (Twitter)',
    'Reddit',
    'Shorts / Reels',
    'Other',
  ];

  String _selectedApp = 'Instagram';
  late final TextEditingController _customAppController;
  late final TextEditingController _durationController;
  late final TextEditingController _notesController;
  String? _inlineError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _customAppController = TextEditingController();
    _durationController = TextEditingController(text: '30');
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _customAppController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final appName = _selectedApp == 'Other'
        ? _customAppController.text.trim()
        : _selectedApp;

    if (appName.isEmpty) {
      setState(() => _inlineError = 'Please specify an app name.');
      return;
    }

    final duration = int.tryParse(_durationController.text.trim());
    if (duration == null || duration <= 0) {
      setState(
        () => _inlineError = 'Please enter a valid duration in minutes.',
      );
      return;
    }

    setState(() {
      _inlineError = null;
      _isSubmitting = true;
    });

    final success = await widget.onSave(
      appName: appName,
      durationMinutes: duration,
      notes: _notesController.text.trim(),
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: AppDimensions.screenPaddingH,
        right: AppDimensions.screenPaddingH,
        top: AppDimensions.spaceL,
        bottom: bottomInset + AppDimensions.spaceL,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Log Scrolling Time', style: AppTypography.headlineSmall),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceM),

            // App Selection Chips
            Text('Select Platform', style: AppTypography.labelLarge),
            const SizedBox(height: AppDimensions.spaceS),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _popularApps.map((app) {
                final isSelected = _selectedApp == app;
                return ChoiceChip(
                  label: Text(app),
                  selected: isSelected,
                  selectedColor: AppColors.primaryForestGreen,
                  backgroundColor: AppColors.cardBackground,
                  labelStyle: AppTypography.labelLarge.copyWith(
                    color: isSelected
                        ? AppColors.lightText
                        : AppColors.primaryText,
                    fontSize: 12,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primaryForestGreen
                        : AppColors.subtleBorder,
                  ),
                  onSelected: (_) {
                    setState(() => _selectedApp = app);
                  },
                );
              }).toList(),
            ),

            if (_selectedApp == 'Other') ...[
              const SizedBox(height: AppDimensions.spaceM),
              TextField(
                controller: _customAppController,
                style: AppTypography.bodyMedium,
                decoration: InputDecoration(
                  labelText: 'Custom App / Site Name *',
                  hintText: 'e.g. TikTok, Pinterest, News App',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                ),
              ),
            ],

            const SizedBox(height: AppDimensions.spaceM),

            // Duration in minutes
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    style: AppTypography.bodyLarge,
                    decoration: InputDecoration(
                      labelText: 'Duration (Minutes) *',
                      suffixText: 'mins',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM,
                        ),
                        borderSide: const BorderSide(
                          color: AppColors.primaryForestGreen,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceS),
                // Quick add duration buttons
                ...[15, 30, 60].map((mins) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(44, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      onPressed: () {
                        setState(() {
                          _durationController.text = mins.toString();
                        });
                      },
                      child: Text('+${mins}m', style: AppTypography.bodySmall),
                    ),
                  );
                }),
              ],
            ),

            const SizedBox(height: AppDimensions.spaceM),

            // Optional note
            TextField(
              controller: _notesController,
              style: AppTypography.bodyMedium,
              decoration: InputDecoration(
                labelText: 'Note (Optional)',
                hintText: 'e.g. Lost track of time watching reels',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
              ),
            ),

            if (_inlineError != null) ...[
              const SizedBox(height: AppDimensions.spaceS),
              Text(
                _inlineError!,
                style: AppTypography.bodySmall.copyWith(
                  color: const Color(0xFFC62828),
                ),
              ),
            ],

            const SizedBox(height: AppDimensions.spaceL),

            AppButton(
              label: _isSubmitting ? 'Saving...' : 'Record Entry',
              icon: Icons.check,
              onPressed: _isSubmitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
