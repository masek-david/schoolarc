import 'package:schoolarc/features/timetable/domain/period_model.dart';
import 'package:schoolarc/features/timetable/domain/timetable_model.dart';
import 'package:schoolarc/models/bakalari/baka_timetable_entry_model.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';

class BakaTimetable {
  BakaTimetable({
    required this.lessonTimes,
    required this.dates,
    required this.table,
  });

  final List<Period> lessonTimes;
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
      periods: lessonTimes,
      dates: dates,
    );
  }
}
