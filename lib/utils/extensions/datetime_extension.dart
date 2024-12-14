import 'package:intl/intl.dart';

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
    DateTime now = DateTime.now();
    DateTime dateOnlyDate = DateTime(year, month, day);
    DateTime nowOnlyDate = DateTime(now.year, now.month, now.day);

    return dateOnlyDate.isBefore(nowOnlyDate) &&
        !dateOnlyDate.isAtSameMomentAs(nowOnlyDate);
  }

  String minuteStartingWithZero() {
    return minute < 10 ? '0$minute' : minute.toString();
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

  /// returns all days in this week
  List<DateTime> allDaysInThisMonth() {
    List<DateTime> list = [];

    int daysInMonth = DateTime(year, month + 1, 0).day;

    for (int i = 1; i <= daysInMonth; i++) {
      list.add(DateTime(year, month, i));
    }

    return list;
  }

  /// formats the date, d. MM. defaultly, if isnt the current year, adds the year, also replaces yesterday, today and tommorow
  String dateText() {
    final localDate = toLocal();
    final now = DateTime.now();

    String text;
    text = DateFormat('d. MM.').format(localDate);
    if (localDate.year != now.year) {
      text = DateFormat('d. MM. y').format(localDate);
    } else if (localDate.isSameDay(now)) {
      text = 'Today';
    } else if (localDate.isSameDay(now.toUtc().add(const Duration(days: 1)))) {
      text = 'Tommorow';
    } else if (localDate
        .isSameDay(now.toUtc().subtract(const Duration(days: -1)))) {
      text = 'Yesterday';
    }
    return text;
  }

  String formattedDate() {
    String year = this.year == DateTime.now().year ? '' : this.year.toString();
    return '$day.$month.$year';
  }
}
