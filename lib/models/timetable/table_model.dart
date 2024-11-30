import 'package:hive/hive.dart';
import 'package:school_manager/models/bakalari/timetable_lesson_model.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';
import 'package:school_manager/models/timetable/lesson_times_model.dart';
import 'package:school_manager/models/timetable/table_dto_model.dart';

part 'table_model.g.dart';

@HiveType(typeId: 3)
class TimeTable {
  // index and times for lessons times
  @HiveField(0)
  List<LessonTimes> lessonTimes = [];
  // list of 7 days, for each day there are as many hours as specified in lessontimes, they are null if empty, and store index of the subject
  @HiveField(1)
  late List<List<int?>> table;

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

  TimeTableDTO convertToDTO(Map<int, SubjectDTO> subjects) {
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
