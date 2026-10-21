import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';
import '../../../../app/app_typography.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../data/models/goal.dart';

class CreateGoalSheet extends StatefulWidget {
  const CreateGoalSheet({super.key, this.existingGoal, required this.onSave});

  final Goal? existingGoal;
  final Future<bool> Function({
    required String title,
    String? description,
    DateTime? targetDate,
    required bool isDailyPriority,
  })
  onSave;

  static Future<void> show({
    required BuildContext context,
    Goal? existingGoal,
    required Future<bool> Function({
      required String title,
      String? description,
      DateTime? targetDate,
      required bool isDailyPriority,
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
      builder: (ctx) =>
          CreateGoalSheet(existingGoal: existingGoal, onSave: onSave),
    );
  }

  @override
  State<CreateGoalSheet> createState() => _CreateGoalSheetState();
}

class _CreateGoalSheetState extends State<CreateGoalSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  DateTime? _selectedTargetDate;
  bool _isDailyPriority = false;
  String? _inlineError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final goal = widget.existingGoal;
    _titleController = TextEditingController(text: goal?.title ?? '');
    _descriptionController = TextEditingController(
      text: goal?.description ?? '',
    );
    _selectedTargetDate = goal?.targetDate;
    _isDailyPriority = goal?.isDailyPriority ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() {
        _inlineError = 'Please enter a goal title.';
      });
      return;
    }

    setState(() {
      _inlineError = null;
      _isSubmitting = true;
    });

    final success = await widget.onSave(
      title: title,
      description: _descriptionController.text.trim(),
      targetDate: _selectedTargetDate,
      isDailyPriority: _isDailyPriority,
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
      if (success) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initialDate = _selectedTargetDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now) ? now : initialDate,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryForestGreen,
              onPrimary: AppColors.lightText,
              surface: AppColors.cardBackground,
              onSurface: AppColors.primaryText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTargetDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingGoal != null;
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
                Text(
                  isEditing ? 'Edit Goal' : 'New Goal',
                  style: AppTypography.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceM),

            // Title input
            TextField(
              controller: _titleController,
              autofocus: true,
              style: AppTypography.bodyLarge,
              decoration: InputDecoration(
                labelText: 'Goal Title *',
                labelStyle: AppTypography.bodyMedium,
                hintText: 'e.g. Finish Chapter 4 or Apply to 2 jobs',
                errorText: _inlineError,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  borderSide: const BorderSide(color: AppColors.subtleBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  borderSide: const BorderSide(
                    color: AppColors.primaryForestGreen,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spaceM),

            // Description input
            TextField(
              controller: _descriptionController,
              style: AppTypography.bodyMedium,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                labelStyle: AppTypography.bodyMedium,
                hintText: 'Add context, steps, or why this matters...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  borderSide: const BorderSide(color: AppColors.subtleBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  borderSide: const BorderSide(
                    color: AppColors.primaryForestGreen,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spaceM),

            // Target Date picker row
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today_outlined, size: 16),
                  label: Text(
                    _selectedTargetDate == null
                        ? 'Set Target Date'
                        : AppDateUtils.formatDisplayDate(_selectedTargetDate!),
                    style: AppTypography.labelLarge,
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceM,
                      vertical: AppDimensions.spaceS,
                    ),
                  ),
                ),
                if (_selectedTargetDate != null) ...[
                  const SizedBox(width: AppDimensions.spaceS),
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      setState(() {
                        _selectedTargetDate = null;
                      });
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppDimensions.spaceM),

            // Daily priority switch
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _isDailyPriority,
              activeTrackColor: AppColors.primaryForestGreen,
              title: Text(
                "Set as Today's Priority",
                style: AppTypography.labelLarge,
              ),
              subtitle: Text(
                'Displays on your Home screen (Maximum 3 active priorities).',
                style: AppTypography.bodySmall,
              ),
              onChanged: (val) {
                setState(() {
                  _isDailyPriority = val;
                });
              },
            ),
            const SizedBox(height: AppDimensions.spaceL),

            // Submit Button
            AppButton(
              label: _isSubmitting
                  ? 'Saving...'
                  : (isEditing ? 'Save Changes' : 'Create Goal'),
              icon: Icons.check,
              onPressed: _isSubmitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
