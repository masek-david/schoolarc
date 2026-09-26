import 'package:flutter/material.dart';
import 'package:schoolarc/features/timetable/domain/lesson_model.dart';
import 'package:schoolarc/features/timetable/domain/period_model.dart';
import 'package:schoolarc/features/timetable/domain/timetable_entity_model.dart';
import 'package:schoolarc/models/date/date.dart';

class Timetable {
  final List<Period> periods;

  /// Optional list of dates of the days in the [table]
  final List<Date>? dates;

  /// list of 7 days, for each day there are as many hours as specified in [periods], they are null if empty
  late final List<List<Lesson>> table;

  Timetable({
    required this.periods,
    required this.table,
    this.dates,
  });

  /// Returns upcoming lessons for date and time
  List<(Period, Lesson)> getUpcomingLessons(DateTime? date) {
    List<(Period, Lesson)> upcomingLessons = [];

    date ??= DateTime.now();
    date = date.toLocal();

    Map<int, Period> upcomingLessonTimes = {};

    for (int i = 0; i < periods.length; i++) {
      final lesson = periods[i];

      if (TimeOfDay(
        hour: date.hour,
        minute: date.minute,
      ).isBefore(lesson.endTime)) {
        upcomingLessonTimes.addAll({i: lesson});
      }
    }

    for (var lessonIndex in upcomingLessonTimes.keys) {
      final lesson = table[date.weekday - 1][lessonIndex];

      upcomingLessons.add((upcomingLessonTimes[lessonIndex]!, lesson));
    }

    return upcomingLessons;
  }

  Date? nextDateForSubject(String? subjectId) {
    if (periods.isEmpty || subjectId == null) {
      return null;
    }

    Date date = Date.today();

    for (int i = date.weekday - 1; i < 100; i++) {
      date = date.addDays(1);
      var listOfSubjects = table[date.weekday - 1].where((element) {
        bool contains = element.subject?.id == subjectId;
        return contains;
      });
      if (listOfSubjects.isNotEmpty) {
        return date;
      }
    }

    return null;
  }

  TimetableEntity toEntity() {
    return TimetableEntity(
      periods: periods,
      table: table.map((e) => e.map((f) => f.toEntity()).toList()).toList(),
    );
  }
}
