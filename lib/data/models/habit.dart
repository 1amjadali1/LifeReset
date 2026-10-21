import 'package:uuid/uuid.dart';

/// Represents a daily habit that the user wants to practice consistently.
class Habit {
  Habit({
    String? id,
    required this.name,
    this.description,
    this.iconCodePoint,
    this.colorHex,
    this.isArchived = false,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  final String id;
  final String name;
  final String? description;
  final int? iconCodePoint;
  final String? colorHex;
  final bool isArchived;
  final DateTime createdAt;

  Habit copyWith({
    String? name,
    String? description,
    int? iconCodePoint,
    String? colorHex,
    bool? isArchived,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorHex: colorHex ?? this.colorHex,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_code_point': iconCodePoint,
      'color_hex': colorHex,
      'is_archived': isArchived ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      iconCodePoint: map['icon_code_point'] as int?,
      colorHex: map['color_hex'] as String?,
      isArchived: (map['is_archived'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Habit &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          iconCodePoint == other.iconCodePoint &&
          colorHex == other.colorHex &&
          isArchived == other.isArchived;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      iconCodePoint.hashCode ^
      colorHex.hashCode ^
      isArchived.hashCode;
}
