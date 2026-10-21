import 'package:uuid/uuid.dart';

/// Represents a manually logged record of time spent on a social-media app.
class SocialMediaEntry {
  SocialMediaEntry({
    String? id,
    required this.appName,
    required this.durationMinutes,
    required this.dateString,
    DateTime? loggedAt,
    this.notes,
  }) : id = id ?? const Uuid().v4(),
       loggedAt = loggedAt ?? DateTime.now();

  final String id;
  final String appName;
  final int durationMinutes;
  final String dateString; // YYYY-MM-DD
  final DateTime loggedAt;
  final String? notes;

  SocialMediaEntry copyWith({
    String? appName,
    int? durationMinutes,
    String? dateString,
    String? notes,
  }) {
    return SocialMediaEntry(
      id: id,
      appName: appName ?? this.appName,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      dateString: dateString ?? this.dateString,
      loggedAt: loggedAt,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'app_name': appName,
      'duration_minutes': durationMinutes,
      'date_string': dateString,
      'logged_at': loggedAt.toIso8601String(),
      'notes': notes,
    };
  }

  factory SocialMediaEntry.fromMap(Map<String, dynamic> map) {
    return SocialMediaEntry(
      id: map['id'] as String,
      appName: map['app_name'] as String,
      durationMinutes: map['duration_minutes'] as int,
      dateString: map['date_string'] as String,
      loggedAt: DateTime.parse(map['logged_at'] as String),
      notes: map['notes'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SocialMediaEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          appName == other.appName &&
          durationMinutes == other.durationMinutes &&
          dateString == other.dateString;

  @override
  int get hashCode =>
      id.hashCode ^
      appName.hashCode ^
      durationMinutes.hashCode ^
      dateString.hashCode;
}
