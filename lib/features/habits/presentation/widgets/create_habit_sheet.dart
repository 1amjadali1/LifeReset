import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';
import '../../../../app/app_typography.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../data/models/habit.dart';

class CreateHabitSheet extends StatefulWidget {
  const CreateHabitSheet({super.key, this.existingHabit, required this.onSave});

  final Habit? existingHabit;
  final Future<bool> Function({
    required String name,
    String? description,
    int? iconCodePoint,
  })
  onSave;

  static Future<void> show({
    required BuildContext context,
    Habit? existingHabit,
    required Future<bool> Function({
      required String name,
      String? description,
      int? iconCodePoint,
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
          CreateHabitSheet(existingHabit: existingHabit, onSave: onSave),
    );
  }

  @override
  State<CreateHabitSheet> createState() => _CreateHabitSheetState();
}

class _CreateHabitSheetState extends State<CreateHabitSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  int _selectedIconCodePoint = Icons.repeat_rounded.codePoint;
  String? _inlineError;
  bool _isSubmitting = false;

  static const List<IconData> _iconOptions = [
    Icons.repeat_rounded,
    Icons.menu_book_rounded,
    Icons.fitness_center_rounded,
    Icons.water_drop_outlined,
    Icons.self_improvement_rounded,
    Icons.directions_walk_rounded,
    Icons.bedtime_outlined,
    Icons.edit_note_rounded,
    Icons.code_rounded,
    Icons.brush_outlined,
  ];

  @override
  void initState() {
    super.initState();
    final habit = widget.existingHabit;
    _nameController = TextEditingController(text: habit?.name ?? '');
    _descriptionController = TextEditingController(
      text: habit?.description ?? '',
    );
    _selectedIconCodePoint =
        habit?.iconCodePoint ?? Icons.repeat_rounded.codePoint;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _inlineError = 'Please enter a habit name.';
      });
      return;
    }

    setState(() {
      _inlineError = null;
      _isSubmitting = true;
    });

    final success = await widget.onSave(
      name: name,
      description: _descriptionController.text.trim(),
      iconCodePoint: _selectedIconCodePoint,
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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingHabit != null;
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
                  isEditing ? 'Edit Habit' : 'New Habit',
                  style: AppTypography.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceM),

            // Name field
            TextField(
              controller: _nameController,
              autofocus: true,
              style: AppTypography.bodyLarge,
              decoration: InputDecoration(
                labelText: 'Habit Name *',
                labelStyle: AppTypography.bodyMedium,
                hintText: 'e.g. Read 15 mins, Morning Walk, 2L Water',
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

            // Description field
            TextField(
              controller: _descriptionController,
              style: AppTypography.bodyMedium,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Why do this habit? (Optional)',
                labelStyle: AppTypography.bodyMedium,
                hintText: 'Connect your daily routine to your larger goal...',
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

            // Icon picker row
            Text('Choose an Icon', style: AppTypography.labelLarge),
            const SizedBox(height: AppDimensions.spaceS),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _iconOptions.map((icon) {
                final isSelected = _selectedIconCodePoint == icon.codePoint;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIconCodePoint = icon.codePoint;
                    });
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryForestGreen
                          : AppColors.accentSurface,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusM,
                      ),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryForestGreen
                            : AppColors.subtleBorder,
                      ),
                    ),
                    child: Icon(
                      icon,
                      size: 22,
                      color: isSelected
                          ? AppColors.lightGreenAccent
                          : AppColors.primaryForestGreen,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppDimensions.spaceL),

            // Submit Button
            AppButton(
              label: _isSubmitting
                  ? 'Saving...'
                  : (isEditing ? 'Save Changes' : 'Create Habit'),
              icon: Icons.check,
              onPressed: _isSubmitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
