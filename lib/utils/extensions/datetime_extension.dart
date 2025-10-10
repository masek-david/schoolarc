import 'package:intl/intl.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/l10n/my_localization.dart';
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
  String formatTime() {
    final date = toLocal();
    if (settings.get(Setting.use24HourFormat)) {
      return DateFormat.Hm().format(date);
    }
    return DateFormat.jm(getLocale().languageCode).format(date);
  }

  /// formats using saved dateformat and using apps language
  String format() {
    return DateFormat(
            settings.get(Setting.dateFormat), getLocale().languageCode)
        .format(this);
  }
}
