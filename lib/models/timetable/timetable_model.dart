import 'package:flutter/material.dart';
import 'package:schoolarc/models/bakalari/timetable_lesson_model.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/models/timetable/lesson_times_model.dart';

class TimeTable {
  List<LessonTimes> lessonTimes;
  List<DateTime>? dates;
  late List<List<TimeTableLesson>> table;

  TimeTable({
    required this.lessonTimes,
    required this.table,
    this.dates,
  });

  /// creates [TimeTable] with lessonTimes, but empty table, so it can be added later
  TimeTable.withoutTable({
    required this.lessonTimes,
  }) {
    table = List.generate(
      7,
      (_) => List.generate(lessonTimes.length, (_) => TimeTableLesson.empty()),
    );
  }

  Map<LessonTimes, TimeTableLesson> getUpcomingLessons(DateTime? date) {
    Map<LessonTimes, TimeTableLesson> upcomingLessons = {};

    date ??= DateTime.now();
    date = date.toLocal();

    Map<int, LessonTimes> upcomingLessonTimes = {};

    for (int i = 0; i < lessonTimes.length; i++) {
      final lesson = lessonTimes[i];

      if (TimeOfDay(hour: date.hour, minute: date.minute)
          .isBefore(lesson.endTime)) {
        upcomingLessonTimes.addAll({i: lesson});
      }
    }

    for (var lessonIndex in upcomingLessonTimes.keys) {
      final lesson = table[date.weekday - 1][lessonIndex];

      upcomingLessons.addAll({upcomingLessonTimes[lessonIndex]!: lesson});
    }

    return upcomingLessons;
  }

  DateTime? nextDateForSubject(Subject subject) {
    if (lessonTimes.isEmpty) {
      return null;
    }

    var now = DateTime.now();
    // int weekday = now.weekday - 1;

    var date = DateTime.utc(now.year, now.month, now.day);

    for (int i = date.weekday - 1; i < 100; i++) {
      date = date.add(const Duration(days: 1));
      var listOfSubjects = table[date.weekday - 1].where((element) {
        bool contains = element.subject?.id == subject.id;
        return contains;
      });
      if (listOfSubjects.isNotEmpty) {
        return date.toLocal();
      }
    }

    return null;
  }
}
