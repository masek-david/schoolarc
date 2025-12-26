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
            settings.get(Setting.dateFormat), context.locale.languageCode)
        .format(this);
  }
}
