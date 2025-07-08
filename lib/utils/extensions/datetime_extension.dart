import 'package:intl/intl.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/l10n/my_localization.dart';
import 'package:school_manager/tasks_app.dart';

extension BetterDateTime on DateTime {
  bool isSameDay(DateTime comparedDate) {
    comparedDate = comparedDate.toLocal();

    final localDate = toLocal();

    return (localDate.year == comparedDate.year &&
        localDate.month == comparedDate.month &&
        localDate.day == comparedDate.day);
  }

  bool isSameMonth(DateTime comparedDate) {
    comparedDate = comparedDate.toLocal();

    final localDate = toLocal();

    return (localDate.year == comparedDate.year &&
        localDate.month == comparedDate.month);
  }

  /// vrati true pokud je date vcera a drive, false pokud dnes
  bool isBeforeToday() {
    final local = toLocal();
    DateTime now = DateTime.now();
    DateTime dateOnlyDate = DateTime(local.year, local.month, local.day);
    DateTime nowOnlyDate = DateTime(now.year, now.month, now.day);

    return dateOnlyDate.isBefore(nowOnlyDate) &&
        !dateOnlyDate.isAtSameMomentAs(nowOnlyDate);
  }

  DateTime onlyDate() {
    return DateTime(year, month, day);
  }

  DateTime toUtcOnlyDate() {
    final dateUtc = toUtc();

    return DateTime.utc(dateUtc.year, dateUtc.month, dateUtc.day);
  }

  /// returns all days in this week
  List<DateTime> allDaysInThisWeek() {
    DateTime firstDay = subtract(Duration(days: weekday - 1));
    List<DateTime> list = [];

    for (int i = 0; i < 7; i++) {
      list.add(firstDay.toUtc().add(Duration(days: i)));
    }

    return list;
  }

  ///includes whole weeks
  List<DateTime> allDaysInMonthCalendarView() {
    List<DateTime> list = [];

    final firstDayOfMonth = DateTime(year, month, 1);
    final firstDayWeekday = firstDayOfMonth.weekday;
    final firstDayIndex = -firstDayWeekday + 2;

    final lastDayOfMonth = DateTime(year, month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final lastDayWeekday = lastDayOfMonth.weekday;
    final lastDayIndex = daysInMonth + (7 - lastDayWeekday);

    for (int i = firstDayIndex; i <= lastDayIndex; i++) {
      list.add(DateTime(year, month, i));
    }

    return list;
  }

  /// returns all days in this month
  List<DateTime> allDaysInThisMonth() {
    List<DateTime> list = [];

    int daysInMonth = DateTime(year, month + 1, 0).day;

    for (int i = 1; i <= daysInMonth; i++) {
      list.add(DateTime(year, month, i));
    }

    return list;
  }

  /// formats using saved dateformat and using apps language
  String format() {
    return DateFormat(
            settings.get(Setting.dateFormat), getLocale().languageCode)
        .format(this);
  }

  /// formats using saved dateformat and using apps language
  String formatTime() {
    if(settings.get(Setting.use24HourFormat)){
      return DateFormat.Hm().format(this);
    }
    return DateFormat.jm(settings.get(Setting.localeLanguage)).format(this);
  }

  /// formats using saved dateformat and using apps language, but if the year is the
  /// same as the current, leave it
  String formatWithoutYear() {
    String format = settings.get(Setting.dateFormat);

    final noYear =
        supportedDateFormatsNoYear[supportedDateFormats.indexOf(format)];

    return DateFormat(noYear, getLocale().languageCode).format(this);
  }

  /// formats the date, replaces yesterday, today and tomorrow, or calls [formatWithoutYear]
  String dateText() {
    final localDate = toLocal();
    final now = DateTime.now();
    final loc = getLocalization();

    if (localDate.isSameDay(now)) {
      return loc.today;
    }
    if (localDate.isSameDay(now.toUtc().add(const Duration(days: 1)))) {
      return loc.tomorrow;
    }
    if (localDate.isSameDay(now.toUtc().subtract(const Duration(days: 1)))) {
      return loc.yesterday;
    }
    return formatWithoutYear();
  }

  /// returns day of week if it is in less than 7 days, else [formatWithoutYear]
  String dayOfWeekText() {
    final localDate = toLocal();
    final now = DateTime.now();

    if (localDate.difference(now) < const Duration(days: 6)) {
      return DateFormat.EEEE(getLocale().languageCode).format(localDate);
    }
    return formatWithoutYear();
  }
}
