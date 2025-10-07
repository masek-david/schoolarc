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

  /// Returs true if this is yesterday and before, false if it's today
  @Deprecated('Use Date instead')
  bool isBeforeToday() {
    final local = toLocal();
    DateTime now = DateTime.now();
    DateTime dateOnlyDate = DateTime(local.year, local.month, local.day);
    DateTime nowOnlyDate = DateTime(now.year, now.month, now.day);

    return dateOnlyDate.isBefore(nowOnlyDate) &&
        !dateOnlyDate.isAtSameMomentAs(nowOnlyDate);
  }

  /// returns all days in this week
  @Deprecated('Use Date instead')
  List<DateTime> allDaysInThisWeek() {
    DateTime firstDay = subtract(Duration(days: weekday - 1));
    List<DateTime> list = [];

    for (int i = 0; i < 7; i++) {
      list.add(firstDay.toUtc().add(Duration(days: i)));
    }

    return list;
  }

  ///includes whole weeks
  @Deprecated('Use Date instead')
  List<DateTime> allDaysInMonthCalendarView() {
    List<DateTime> list = [];
    final startOnMonday = settings.get(Setting.weekStartsOnMonday);

    final firstDayOfMonth = DateTime(year, month, 1);
    final firstDayWeekday = firstDayOfMonth.weekday;
    final firstDayIndex = -firstDayWeekday + (startOnMonday ? 2 : 1);

    final lastDayOfMonth = DateTime(year, month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final lastDayWeekday = lastDayOfMonth.weekday;
    final lastDayIndex =
        daysInMonth + ((startOnMonday ? 7 : 6) - lastDayWeekday);

    for (int i = firstDayIndex; i <= lastDayIndex; i++) {
      list.add(DateTime(year, month, i));
    }

    return list;
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

  /// formats using saved dateformat and using apps language, but if the year is the
  /// same as the current, leave it
  @Deprecated('Use Date instead')
  String formatWithoutYear() {
    String dateFormat = settings.get(Setting.dateFormat);

    final format = year == DateTime.now().year
        ? supportedDateFormatsNoYear[supportedDateFormats.indexOf(dateFormat)]
        : dateFormat;

    return DateFormat(format, getLocale().languageCode).format(toLocal());
  }

  /// formats the date, replaces yesterday, today and tomorrow, or calls [formatWithoutYear]
  @Deprecated('Use Date instead')
  String dateText() {
    final localDate = toLocal();
    final now = DateTime.now();
    final loc = getLocalization();

    if (localDate.isSameDay(now)) {
      return loc.today;
    }
    if (localDate
        .isSameDay(now.toUtc().add(const Duration(days: 1)).toLocal())) {
      return loc.tomorrow;
    }
    if (localDate
        .isSameDay(now.toUtc().subtract(const Duration(days: 1)).toLocal())) {
      return loc.yesterday;
    }
    return formatWithoutYear();
  }

  /// returns day of week if it is in less than 7 days, else [formatWithoutYear]
  @Deprecated('Use Date instead')
  String dayOfWeekText() {
    final localDate = toLocal();
    final now = DateTime.now();

    if (localDate.difference(now) < const Duration(days: 6)) {
      return DateFormat.EEEE(getLocale().languageCode).format(localDate);
    }
    return formatWithoutYear();
  }
}
