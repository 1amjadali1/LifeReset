import 'package:uuid/uuid.dart';

/// Represents a user-defined goal.
class Goal {
  Goal({
    String? id,
    required this.title,
    this.description,
    this.targetDate,
    this.isCompleted = false,
    this.isDailyPriority = false,
    this.completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String title;
  final String? description;
  final DateTime? targetDate;
  final bool isCompleted;
  final bool isDailyPriority;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Returns true if this goal has a target date in the past and is not yet completed.
  bool get isOverdue {
    if (isCompleted || targetDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(
      targetDate!.year,
      targetDate!.month,
      targetDate!.day,
    );
    return target.isBefore(today);
  }

  Goal copyWith({
    String? title,
    String? description,
    DateTime? targetDate,
    bool? isCompleted,
    bool? isDailyPriority,
    DateTime? completedAt,
    bool clearDescription = false,
    bool clearTargetDate = false,
  }) {
    return Goal(
      id: id,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      targetDate: clearTargetDate ? null : (targetDate ?? this.targetDate),
      isCompleted: isCompleted ?? this.isCompleted,
      isDailyPriority: isDailyPriority ?? this.isDailyPriority,
      completedAt: isCompleted == false
          ? null
          : (completedAt ?? this.completedAt),
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'target_date': targetDate?.toIso8601String(),
      'is_completed': isCompleted ? 1 : 0,
      'is_daily_priority': isDailyPriority ? 1 : 0,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      targetDate: map['target_date'] != null
          ? DateTime.parse(map['target_date'] as String)
          : null,
      isCompleted: (map['is_completed'] as int) == 1,
      isDailyPriority: (map['is_daily_priority'] as int) == 1,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Goal &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          targetDate == other.targetDate &&
          isCompleted == other.isCompleted &&
          isDailyPriority == other.isDailyPriority;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      targetDate.hashCode ^
      isCompleted.hashCode ^
      isDailyPriority.hashCode;
}
