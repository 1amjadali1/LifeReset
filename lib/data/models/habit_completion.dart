import 'package:uuid/uuid.dart';

/// Represents a single recorded completion of a habit for a specific calendar date.
class HabitCompletion {
  HabitCompletion({
    String? id,
    required this.habitId,
    required this.dateString,
    DateTime? completedAt,
  }) : id = id ?? const Uuid().v4(),
       completedAt = completedAt ?? DateTime.now();

  final String id;
  final String habitId;
  final String dateString; // YYYY-MM-DD
  final DateTime completedAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'date_string': dateString,
      'completed_at': completedAt.toIso8601String(),
    };
  }

  factory HabitCompletion.fromMap(Map<String, dynamic> map) {
    return HabitCompletion(
      id: map['id'] as String,
      habitId: map['habit_id'] as String,
      dateString: map['date_string'] as String,
      completedAt: DateTime.parse(map['completed_at'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitCompletion &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          habitId == other.habitId &&
          dateString == other.dateString;

  @override
  int get hashCode => id.hashCode ^ habitId.hashCode ^ dateString.hashCode;
}
