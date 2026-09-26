import 'package:schoolarc/features/timetable/domain/lesson_entity_model.dart';
import 'package:schoolarc/features/timetable/domain/lesson_model.dart';
import 'package:schoolarc/features/timetable/domain/period_model.dart';
import 'package:schoolarc/features/timetable/domain/timetable_model.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';

class TimetableEntity {
  const TimetableEntity({required this.periods, required this.table});

  final List<Period> periods;

  /// list of 7 days, for each day there are as many hours as specified in [periods], they are null if empty
  final List<List<LessonEntity>> table;

  /// creates [Timetable] with only [periods], but empty [table]
  TimetableEntity.fromPeriods({
    required this.periods,
  }) : table = List.generate(
         7,
         (_) =>
             List.generate(periods.length, (_) => const LessonEntity.empty()),
       );

  Timetable convert(Map<String, Subject> idToSubject) {
    var convertedTable = table.map(
      (day) {
        return day.map(
          (lesson) {
            final subject = idToSubject[lesson.subjectId];
            return Lesson(
              subject: subject,
              teacher: lesson.teacher,
              room: lesson.room,
              change: null,
            );
          },
        ).toList();
      },
    ).toList();

    return Timetable(
      periods: periods,
      table: convertedTable,
    );
  }

  TimetableEntity copyWith({
    List<Period>? periods,
    List<List<LessonEntity>>? table,
  }) {
    return TimetableEntity(
      periods: periods ?? this.periods,
      table: table ?? this.table,
    );
  }
}
