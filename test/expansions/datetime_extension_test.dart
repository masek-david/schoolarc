import 'package:flutter_test/flutter_test.dart';

import 'package:school_manager/utils/extensions/datetime_extension.dart';

void main() {
  test(
    'isSameDay should return true for two DateTime objects on the same day',
    () {
      final date1 = DateTime(2024, 1, 1, 23, 59);
      final date2 = DateTime(2024, 1, 1, 0, 0);

      expect(date1.isSameDay(date2), true);
    },
  );

  test(
    'isSameDay should return true for two UTC DateTime objects on the same day',
    () {
      final date1 = DateTime(2024, 1, 1, 23, 59).toUtc();
      final date2 = DateTime(2024, 1, 1, 0, 0).toUtc();

      expect(date1.isSameDay(date2), true);
    },
  );

  test(
    'isSameDay should return false for two DateTime objects on different days',
    () {
      final date1 = DateTime(2024, 1, 1, 23, 59);
      final date2 = DateTime(2024, 1, 2, 0, 0);

      expect(date1.isSameDay(date2), false);
    },
  );

  test(
    'isSameDay should return false for two DateTime objects in different years',
    () {
      final date1 = DateTime(2023, 12, 31, 23, 59);
      final date2 = DateTime(2024, 1, 1, 0, 0);

      expect(date1.isSameDay(date2), false);
    },
  );

  test(
    'isSameDay should return false for two DateTime objects in different months',
    () {
      final date1 = DateTime(2024, 1, 31, 23, 59);
      final date2 = DateTime(2024, 2, 1, 0, 0);

      expect(date1.isSameDay(date2), false);
    },
  );

  test(
    'isSameDay should return true for the exact same DateTime object',
    () {
      final date1 = DateTime(2024, 1, 1, 12, 0);
      final date2 = DateTime(2024, 1, 1, 12, 0);

      expect(date1.isSameDay(date2), true);
    },
  );
}
