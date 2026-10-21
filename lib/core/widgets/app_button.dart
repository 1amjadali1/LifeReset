import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../app/app_typography.dart';
import '../constants/app_dimensions.dart';

enum AppButtonVariant { primary, secondary, accent }

/// A reusable, touch-friendly button following the Life Reset design system.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.isFullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;

    Color bgColor;
    Color fgColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case AppButtonVariant.primary:
        bgColor = isEnabled
            ? AppColors.primaryForestGreen
            : AppColors.disabledBackground;
        fgColor = isEnabled ? AppColors.lightText : AppColors.disabledText;
      case AppButtonVariant.secondary:
        bgColor = Colors.transparent;
        fgColor = isEnabled
            ? AppColors.primaryForestGreen
            : AppColors.disabledText;
        borderSide = BorderSide(
          color: isEnabled
              ? AppColors.primaryForestGreen
              : AppColors.disabledText,
          width: 1.2,
        );
      case AppButtonVariant.accent:
        bgColor = isEnabled
            ? AppColors.lightGreenAccent
            : AppColors.disabledBackground;
        fgColor = isEnabled
            ? AppColors.primaryForestGreen
            : AppColors.disabledText;
    }

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: fgColor),
          const SizedBox(width: AppDimensions.spaceS),
        ],
        Text(label, style: AppTypography.labelLarge.copyWith(color: fgColor)),
      ],
    );

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          elevation: 0,
          side: borderSide,
          minimumSize: isFullWidth
              ? const Size(double.infinity, 48)
              : const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceL,
            vertical: AppDimensions.spaceS,
          ),
        ),
        child: content,
      ),
    );
  }
}
