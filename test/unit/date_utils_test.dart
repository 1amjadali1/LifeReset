import 'package:flutter_test/flutter_test.dart';
import 'package:life_reset/core/utils/date_utils.dart';

void main() {
  group('AppDateUtils Tests', () {
    test('toDateString formats accurately into YYYY-MM-DD', () {
      final date = DateTime(2026, 10, 21, 14, 30);
      expect(AppDateUtils.toDateString(date), '2026-10-21');
    });

    test('parseDateString parses YYYY-MM-DD into DateTime at start of day', () {
      final parsed = AppDateUtils.parseDateString('2026-10-21');
      expect(parsed.year, 2026);
      expect(parsed.month, 10);
      expect(parsed.day, 21);
      expect(parsed.hour, 0);
      expect(parsed.minute, 0);
    });

    test('daysBetween computes exact calendar days', () {
      final day1 = DateTime(2026, 10, 10, 23, 59);
      final day2 = DateTime(2026, 10, 15, 1, 0);
      expect(AppDateUtils.daysBetween(day1, day2), 5);
      expect(AppDateUtils.daysBetween(day2, day1), -5);
    });

    test('formatDisplayDate handles relative today/yesterday cleanly', () {
      final now = DateTime.now();
      expect(AppDateUtils.formatDisplayDate(now), 'Today');

      final yesterday = now.subtract(const Duration(days: 1));
      expect(AppDateUtils.formatDisplayDate(yesterday), 'Yesterday');
    });
  });
}
