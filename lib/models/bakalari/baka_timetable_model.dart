import 'package:schoolarc/models/bakalari/baka_timetable_entry_model.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/models/timetable/lesson_times_model.dart';
import 'package:schoolarc/models/timetable/timetable_model.dart';

class BakaTimetable {
  BakaTimetable({
    required this.lessonTimes,
    required this.dates,
    required this.table,
  });

  final List<LessonTimes> lessonTimes;
  final List<Date> dates;
  final List<List<BakaTimetableEntry>> table;

  /// Converts to Timetable, assigning subjects
  Timetable toTimetable(List<Subject> subjects) {
    // create Map<bakaId, Subject>
    final subjectsMap = {
      for (final s in subjects)
        if (s.bakaId != null) s.bakaId!: s,
    };

    final newTable = table
        .map(
          (day) =>
              day.map((entry) => entry.toTimetableEntry(subjectsMap)).toList(),
        )
        .toList();

    return Timetable(
      table: newTable,
      lessonTimes: lessonTimes,
      dates: dates,
    );
  }
}
