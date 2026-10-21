import 'package:flutter/material.dart';

abstract final class AppIcons {
  static const List<IconData> habitIcons = [
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

  static IconData getHabitIcon(int? codePoint) {
    if (codePoint == null) return Icons.repeat_rounded;
    for (final icon in habitIcons) {
      if (icon.codePoint == codePoint) return icon;
    }
    return Icons.repeat_rounded;
  }
}
