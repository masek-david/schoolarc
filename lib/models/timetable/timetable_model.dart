import 'package:flutter/material.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/timetable/lesson_times_model.dart';
import 'package:schoolarc/models/timetable/timetable_entity_model.dart';
import 'package:schoolarc/models/timetable/timetable_entry_model.dart';

class Timetable {
  final List<LessonTimes> lessonTimes;
  final List<Date>? dates;
  late final List<List<TimetableEntry>> table;

  Timetable({
    required this.lessonTimes,
    required this.table,
    this.dates,
  });

  /// creates [Timetable] with lessonTimes, but empty table, so it can be added later
  factory Timetable.withoutTable({
    required List<LessonTimes> lessonTimes,
  }) {
    final table = List.generate(
      7,
      (_) => List.generate(lessonTimes.length, (_) => TimetableEntry.empty()),
    );
    return Timetable(lessonTimes: lessonTimes, table: table);
  }

  /// Returns upcoming lessons for date and time
  List<(LessonTimes, TimetableEntry)> getUpcomingLessons(DateTime? date) {
    List<(LessonTimes, TimetableEntry)> upcomingLessons = [];

    date ??= DateTime.now();
    date = date.toLocal();

    Map<int, LessonTimes> upcomingLessonTimes = {};

    for (int i = 0; i < lessonTimes.length; i++) {
      final lesson = lessonTimes[i];

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
    if (lessonTimes.isEmpty || subjectId == null) {
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

  TimeTableEntity toEntity() {
    return TimeTableEntity(
      lessonTimes,
      table
          .map(
            (e) => e
                .map(
                  (e) => e.subject?.id,
                )
                .toList(),
          )
          .toList(),
    );
  }
}
