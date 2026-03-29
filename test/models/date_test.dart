import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:schoolarc/models/date/date.dart';

void main() {
  group('Date class', () {
    test('creates from int and converts back correctly', () {
      final date = Date.fromPrimitiveInt(20250930);
      expect(date.year, 2025);
      expect(date.month, 9);
      expect(date.day, 30);
      expect(date.toPrimitiveInt(), 20250930);
    });

    test('creates from DateTime correctly', () {
      final dt = DateTime(2023, 5, 10);
      final date = Date.fromDateTime(dt);
      expect(date.year, 2023);
      expect(date.month, 5);
      expect(date.day, 10);
    });

    test('now() creates today’s date', () {
      final now = DateTime.now();
      final date = Date.today();
      expect(date.year, now.year);
      expect(date.month, now.month);
      expect(date.day, now.day);
    });

    test('toString returns formatted YYYY-MM-DD', () {
      initializeDateFormatting('en');

      final date = const Date(2025, 9, 30);
      expect(date.toString(), '2025-09-30');
      expect(DateTime.parse(date.toString()), DateTime(2025, 9, 30));
    });

    test(
      'compareTo returns correct values',
      () {
        final a = const Date(2025, 9, 30);
        final b = const Date(2024, 9, 30);
        final c = const Date(2025, 9, 1);
        final d = const Date(2025, 10, 30);

        expect(a.compareTo(a), 0);
        expect(a.compareTo(b), 1);
        expect(a.compareTo(c), 1);
        expect(a.compareTo(d), -1);

        final list = [a, b, c, d]..sort();
        expect(list, [b, c, a, d]);
      },
    );

    test('isSameDay, isSameMonth, isSameYear work correctly', () {
      final a = const Date(2025, 9, 30);
      final b = const Date(2025, 9, 30);
      final c = const Date(2025, 9, 1);
      final d = const Date(2025, 8, 30);
      final e = const Date(2024, 9, 30);

      expect(a.isSameDay(b), true);
      expect(a.isSameMonth(b), true);
      expect(a.isSameYear(b), true);

      expect(a.isSameDay(c), false);
      expect(a.isSameMonth(c), true);
      expect(a.isSameYear(c), true);

      expect(a.isSameDay(d), false);
      expect(a.isSameMonth(d), false);
      expect(a.isSameYear(d), true);

      expect(a.isSameDay(e), false);
      expect(a.isSameMonth(e), false);
      expect(a.isSameYear(e), false);
    });

    test('isBefore and isAfter behave correctly', () {
      final a = const Date(2025, 9, 30);
      final b = const Date(2025, 10, 1);

      expect(a.isBefore(b), true);
      expect(b.isAfter(a), true);
      expect(a.isAfter(b), false);
      expect(b.isBefore(a), false);
    });

    test('addDays and subtractDays work correctly', () {
      final date = const Date(2025, 9, 30);
      expect(date.addDays(1).day, 1);
      expect(date.addDays(1).month, 10);
      expect(date.subtractDays(1).day, 29);
    });

    test('Date.difference returns correct day difference', () {
      final a = const Date(2025, 10, 10);
      final b = const Date(2025, 10, 9);
      final c = const Date(2025, 10, 5);

      expect(a.difference(a), 0);
      expect(a.difference(b), 1);
      expect(b.difference(a), -1);
      expect(a.difference(c), 5);
    });

    test('weekday returns correct value', () {
      // 2025-09-30 is Tuesday (weekday = 2)
      final date = const Date(2025, 9, 30);
      expect(date.weekday, 2);
    });

    test('toDateTimeLocal returns correct date', () {
      final date = const Date(2025, 9, 30);
      final local = date.toDateTimeLocal();
      expect(local.year, date.year);
      expect(local.month, date.month);
      expect(local.day, date.day);
      expect(local.isUtc, false);
    });

    test('toDateTimeUtc returns correct date', () {
      final date = const Date(2025, 9, 30);
      final utc = date.toDateTimeUTC();
      expect(utc.year, date.year);
      expect(utc.month, date.month);
      expect(utc.day, date.day);
      expect(utc.isUtc, true);
    });

    test(
      'format() correctly formats date for different patterns and locales',
      () {
        initializeDateFormatting('en');
        initializeDateFormatting('cs');
        final date = const Date(2025, 10, 6);

        expect(date.format('yyyy-MM-dd', 'en'), '2025-10-06');
        expect(date.format('dd/MM/yyyy', 'cs'), '06/10/2025');

        // English vs Czech month names
        final englishMonth = date.format('MMMM', 'en').toLowerCase();
        final czechMonth = date.format('MMMM', 'cs').toLowerCase();

        expect(englishMonth, 'october');
        expect(czechMonth, 'říjen');
      },
    );

    test('allDaysInThisMonth returns correct days', () {
      final feb = const Date(2024, 2, 13); // leap year
      final list = feb.allDaysInThisMonth();
      expect(list.length, 29);
      expect(list.first, const Date(2024, 2, 1));
      expect(list.last, const Date(2024, 2, 29));
    });

    test('allDaysInThisWeek returns correct days', () {
      final date = const Date(2025, 9, 30);
      final week = date.allDaysInThisWeek(startOnMonday: true);
      final weekFromSunday = date.allDaysInThisWeek(startOnMonday: false);
      expect(week.length, 7);
      expect(week.first, const Date(2025, 9, 29)); // Monday
      expect(week.last, const Date(2025, 10, 5)); // Sunday
      expect(weekFromSunday.length, 7);
      expect(weekFromSunday.first, const Date(2025, 9, 28)); // Sunday
      expect(weekFromSunday.last, const Date(2025, 10, 4)); // Saturday
    });

    test('allDaysInMonthCalendarView returns correct days', () {
      final date = const Date(2025, 9, 15);
      final list = date.allDaysInMonthCalendarView(true);
      final listFromSunday = date.allDaysInMonthCalendarView(false);
      // September 2025 starts on Monday, ends on Tuesday → 30 days
      // Should cover full 5 weeks (35 days)
      expect(list.length, 35);
      expect(list.first, const Date(2025, 9, 1)); // Monday
      expect(list.last, const Date(2025, 10, 5)); // Sunday
      expect(listFromSunday.length, 35);
      expect(listFromSunday.first, const Date(2025, 8, 31)); // Sunday
      expect(listFromSunday.last, const Date(2025, 10, 4)); // Saturday
    });
  });
}
