/// Centralized date utilities for Life Reset.
/// Ensures consistent calendar-day calculations in the local timezone.
abstract final class AppDateUtils {
  /// Converts a [DateTime] to a strict `YYYY-MM-DD` calendar-date string in local time.
  static String toDateString(DateTime date) {
    final local = date.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Parses a `YYYY-MM-DD` string back into a local [DateTime] at start-of-day (00:00:00).
  static DateTime parseDateString(String dateString) {
    final parts = dateString.split('-');
    if (parts.length != 3) {
      throw FormatException('Invalid date format: $dateString');
    }
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  /// Returns today's date as a `YYYY-MM-DD` string.
  static String get todayString => toDateString(DateTime.now());

  /// Returns yesterday's date as a `YYYY-MM-DD` string.
  static String get yesterdayString {
    final now = DateTime.now();
    return toDateString(now.subtract(const Duration(days: 1)));
  }

  /// Returns a normalized [DateTime] with hour, minute, second, and millisecond stripped.
  static DateTime startOfDay(DateTime date) {
    final local = date.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  /// Calculates the difference in full calendar days between two dates.
  static int daysBetween(DateTime a, DateTime b) {
    final startA = startOfDay(a);
    final startB = startOfDay(b);
    return startB.difference(startA).inDays;
  }

  /// Formats a date for human-readable display (e.g. "Wed, 21 Oct" or "Today").
  static String formatDisplayDate(DateTime date) {
    final now = DateTime.now();
    final diff = daysBetween(date, now);

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff == -1) return 'Tomorrow';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final local = date.toLocal();
    return '${weekdays[local.weekday - 1]}, ${local.day} ${months[local.month - 1]}';
  }
}
