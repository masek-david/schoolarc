import 'package:hive_ce/hive.dart';
import 'package:school_manager/models/bakalari/timetable_lesson_model.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';
import 'package:school_manager/models/timetable/lesson_times_model.dart';
import 'package:school_manager/models/timetable/timetable_dto_model.dart';

class TimeTable extends HiveObject {
  // index and times for lessons times
  List<LessonTimes> lessonTimes = [];
  // list of 7 days, for each day there are as many hours as specified in lessontimes, they are null if empty, and store index of the subject
  late List<List<String?>> table;

  TimeTable(this.lessonTimes) {
    table = List.generate(
        7, (_) => List.filled(lessonTimes.length, null, growable: true));
  }

  TimeTable.empty() {
    lessonTimes = [];
    table = List.generate(
      7,
      (_) => List.filled(lessonTimes.length, null, growable: true),
    );
  }

  TimeTableDTO convertToDTO(Map<String, SubjectDTO> subjects) {
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

    return TimeTableDTO(
      lessonTimes: lessonTimes,
      table: convertedTable,
    );
  }
}
