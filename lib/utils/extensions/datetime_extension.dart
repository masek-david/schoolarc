import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';

extension BetterDateTime on DateTime {
  bool isSameDay(DateTime comparedDate) {
    comparedDate = comparedDate.toLocal();

    final localDate = toLocal();

    return (localDate.year == comparedDate.year &&
        localDate.month == comparedDate.month &&
        localDate.day == comparedDate.day);
  }

  /// Returns String of Time using saved date format and using apps language
  String formatTime(BuildContext context) {
    final date = toLocal();
    if (settings.get(Setting.use24HourFormat)) {
      return DateFormat.Hm().format(date);
    }
    return DateFormat.jm(context.locale.languageCode).format(date);
  }

  /// formats using saved dateformat and using apps language
  String format(BuildContext context) {
    return DateFormat(
      settings.get(Setting.dateFormat),
      context.locale.languageCode,
    ).format(toLocal());
  }

  /// Returns the number of the week this datetime is part of
  int get weekSinceEpoch {
    // substract 4 days, because 1.1.1970 was a thursday
    return ((millisecondsSinceEpoch - 4 * millisecondsInDay) /
            (7 * millisecondsInDay))
        .floor();
  }

  DateTime copyAsUtc(){
    return DateTime.utc(year, month, day, minute, second, millisecond, microsecond);
  }
}
