import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';

part 'date.g.dart';

// I dont extend HiveObject so Date can have const constructor
// Maybe we dont have to save it?
@HiveType(typeId: 100)
class Date implements Comparable<Date> {
  @HiveField(0)
  final int year;
  @HiveField(1)
  final int month;
  @HiveField(2)
  final int day;

  const Date(this.year, this.month, this.day);
  // TODO how to ensure that this number is valid ?

  factory Date.today() {
    final now = DateTime.now();
    return Date(now.year, now.month, now.day);
  }

  Date.fromPrimitiveInt(int dateInt)
      : year = dateInt ~/ 10000,
        month = (dateInt % 10000) ~/ 100,
        day = dateInt % 100;

  /// Just saves the date, so keeps utc/local
  Date.fromDateTime(DateTime dateTime)
      : year = dateTime.year,
        month = dateTime.month,
        day = dateTime.day;

  int toPrimitiveInt() {
    return year * 10000 + month * 100 + day;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Date &&
        other.year == year &&
        other.month == month &&
        other.day == day;
  }

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() {
    return format('yyyy-MM-dd', 'en');
  }

  /// Returns -1 if other is before this, 1 if other is after this and 0 if they are the same
  @override
  int compareTo(Date other) {
    if (isBefore(other)) return -1;
    if (isAfter(other)) return 1;
    return 0;
  }

  bool isSameDay(Date other) {
    return day == other.day && month == other.month && year == other.year;
  }

  bool isSameMonth(Date other) {
    return month == other.month && year == other.year;
  }

  bool isSameYear(Date other) {
    return year == other.year;
  }

  bool isBefore(Date other) {
    if (year > other.year) return false;
    if (year < other.year) return true;

    if (month > other.month) return false;
    if (month < other.month) return true;

    return day < other.day;
  }

  bool isAfter(Date other) {
    if (year > other.year) return true;
    if (year < other.year) return false;

    if (month > other.month) return true;
    if (month < other.month) return false;

    return day > other.day;
  }

  Date addDays(int daysToAdd) {
    final dateTime = toDateTimeUTC().add(Duration(days: daysToAdd));
    return Date(dateTime.year, dateTime.month, dateTime.day);
  }

  Date subtractDays(int daysToSubtract) {
    final dateTime = toDateTimeUTC().subtract(Duration(days: daysToSubtract));
    return Date(dateTime.year, dateTime.month, dateTime.day);
  }

  int get weekday {
    return toDateTimeLocal().weekday;
  }

  DateTime toDateTimeLocal() {
    return DateTime(year, month, day);
  }

  DateTime toDateTimeUTC() {
    return DateTime.utc(year, month, day);
  }

  String format(String format, String languageCode) {
    return DateFormat(format, languageCode).format(toDateTimeLocal());
  }

  /// returns all days in this week
  List<Date> allDaysInThisWeek(bool startOnMonday) {
    Date firstDay = subtractDays(weekday - (startOnMonday ? 1 : 0));
    List<Date> list = [];

    for (int i = 0; i < 7; i++) {
      list.add(firstDay.addDays(i));
    }

    return list;
  }

  /// returns all days in this month
  List<Date> allDaysInThisMonth() {
    List<Date> list = [];

    int daysInMonth = DateTime(year, month + 1, 0).day;

    for (int i = 1; i <= daysInMonth; i++) {
      list.add(Date(year, month, i));
    }

    return list;
  }

  /// includes whole weeks
  List<Date> allDaysInMonthCalendarView(bool startOnMonday) {
    List<Date> list = [];

    final firstDayOfMonth = Date(year, month, 1);
    final firstDayOfMonthWeekday = firstDayOfMonth.weekday;
    final firstDayIndex = -firstDayOfMonthWeekday + (startOnMonday ? 1 : 0);

    final lastDayOfMonth = DateTime(year, month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final lastDayWeekday = lastDayOfMonth.weekday;
    final lastDayIndex =
        daysInMonth + ((startOnMonday ? 6 : 5) - lastDayWeekday);

    for (int i = firstDayIndex; i <= lastDayIndex; i++) {
      list.add(firstDayOfMonth.addDays(i));
    }

    return list;
  }
}

class RestorableDate extends RestorableValue<Date> {
  RestorableDate(this._defaultValue);

  final Date _defaultValue;

  @override
  Date createDefaultValue() => _defaultValue;

  @override
  void didUpdateValue(Date? oldValue) {
    if (oldValue == null || oldValue != value) {
      notifyListeners();
    }
  }

  @override
  Date fromPrimitives(Object? data) {
    if (data != null) {
      return Date.fromPrimitiveInt(data as int);
    }
    return Date.today();
  }

  @override
  Object toPrimitives() {
    return value.toPrimitiveInt();
  }
}
