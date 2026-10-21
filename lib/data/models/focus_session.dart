import 'package:uuid/uuid.dart';

/// Represents a completed deep-focus session.
class FocusSession {
  FocusSession({
    String? id,
    required this.durationMinutes,
    required this.actualElapsedSeconds,
    this.goalId,
    this.label,
    required this.startedAt,
    required this.completedAt,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final int durationMinutes;
  final int actualElapsedSeconds;
  final String? goalId;
  final String? label;
  final DateTime startedAt;
  final DateTime completedAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'duration_minutes': durationMinutes,
      'actual_elapsed_seconds': actualElapsedSeconds,
      'goal_id': goalId,
      'label': label,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt.toIso8601String(),
    };
  }

  factory FocusSession.fromMap(Map<String, dynamic> map) {
    return FocusSession(
      id: map['id'] as String,
      durationMinutes: map['duration_minutes'] as int,
      actualElapsedSeconds: map['actual_elapsed_seconds'] as int,
      goalId: map['goal_id'] as String?,
      label: map['label'] as String?,
      startedAt: DateTime.parse(map['started_at'] as String),
      completedAt: DateTime.parse(map['completed_at'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FocusSession &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          durationMinutes == other.durationMinutes &&
          actualElapsedSeconds == other.actualElapsedSeconds &&
          goalId == other.goalId &&
          label == other.label;

  @override
  int get hashCode =>
      id.hashCode ^
      durationMinutes.hashCode ^
      actualElapsedSeconds.hashCode ^
      goalId.hashCode ^
      label.hashCode;
}
