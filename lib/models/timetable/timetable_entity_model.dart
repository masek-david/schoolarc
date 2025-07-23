import 'package:hive_ce/hive.dart';
import 'package:school_manager/models/bakalari/timetable_lesson_model.dart';
import 'package:school_manager/models/subjects/subject_model.dart';
import 'package:school_manager/models/timetable/lesson_times_model.dart';
import 'package:school_manager/models/timetable/timetable_model.dart';

class TimeTableEntity extends HiveObject {
  // index and times for lessons times
  List<LessonTimes> lessonTimes = [];
  // list of 7 days, for each day there are as many hours as specified in lessontimes, they are null if empty, and store index of the subject
  late List<List<String?>> table;

  /// creates [TimeTableEntity], if lessonTimes is null, it will be [], and if table is null, it will fill it with empty lessons
  TimeTableEntity(List<LessonTimes>? lessonTimes, List<List<String?>>? table) {
    this.lessonTimes = lessonTimes ?? [];

    this.table = table ??
        List.generate(
          7,
          (_) => List.filled(this.lessonTimes.length, null, growable: true),
        );
  }

  TimeTable convert(Map<String, Subject> subjects) {
    var convertedTable = table.map(
      (day) {
        return day.map(
          (subjectIndex) {
            final subject = subjects[subjectIndex];
            return TimeTableLesson(
              subject: subject,
              change: null,
            );
          },
        ).toList();
      },
    ).toList();

    return TimeTable(
      lessonTimes: lessonTimes,
      table: convertedTable,
    );
  }
}
