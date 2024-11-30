import 'package:flutter/material.dart';
import 'package:school_manager/models/bakalari/timetable_lesson_model.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';
import 'package:school_manager/models/timetable/lesson_times_model.dart';
import 'package:school_manager/utils/extensions/timeofday_extension.dart';

class TimeTableDTO {
  TimeTableDTO({
    required this.lessonTimes,
    List<List<TimeTableLesson>>? table,
    this.dates,
  }) {
    if (table == null) {
      this.table = List.generate(
        7,
        (_) =>
            List.generate(lessonTimes.length, (_) => TimeTableLesson.empty()),
      );
    } else {
      this.table = table;
    }
  }

  List<LessonTimes> lessonTimes;
  List<DateTime>? dates;
  late List<List<TimeTableLesson>> table;

  Map<LessonTimes, TimeTableLesson> getUpcomingLessons(DateTime? date) {
    Map<LessonTimes, TimeTableLesson> upcomingLessons = {};

    date ??= DateTime.now();
    date = date.toLocal();

    // final now = DateTime(2024, 11, 12, 7, 45);
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

  DateTime? nextDateForSubject(SubjectDTO subject) {
    if (lessonTimes.isEmpty) {
      return null;
    }

    var now = DateTime.now();
    // int weekday = now.weekday - 1;

    var date = DateTime.utc(now.year, now.month, now.day);

    for (int i = date.weekday - 1; i < 100; i++) {
      date = date.add(const Duration(days: 1));
      var listOfSubjects = table[date.weekday - 1].where((element) {
        bool contains = element.subject?.dbIndex == subject.dbIndex;
        return contains;
      });
      if (listOfSubjects.isNotEmpty) {
        return date.toLocal();
      }
    }

    return null;
  }
}
