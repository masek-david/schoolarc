import 'package:schoolarc/features/timetable/domain/lesson_change_model.dart';
import 'package:schoolarc/features/timetable/domain/lesson_model.dart';
import 'package:schoolarc/features/timetable/domain/teacher_model.dart';
import 'package:schoolarc/models/bakalari/baka_subject_model.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';

class BakaTimetableEntry {
  BakaTimetableEntry({
    required this.change,
    required this.teacher,
    required this.room,
    required this.bakaSubject,
  });

  BakaTimetableEntry.empty()
    : change = null,
      bakaSubject = null,
      room = null,
      teacher = null;

  final LessonChange? change;
  final Teacher? teacher;
  final String? room;
  final BakaSubject? bakaSubject;

  /// Converts to TimetableEntry, assigns existing subject from subjects (which is map of bakaId:Subject),
  /// if there is no correct subject, creates new, that can be later saved
  Lesson toTimetableEntry(Map<String, Subject> subjects) {
    late final Subject? finalSubject;

    if (bakaSubject == null) {
      finalSubject = null;
    } else {
      finalSubject =
          subjects[bakaSubject!.id] ??
          Subject(
            name: bakaSubject!.name,
            shortcut: bakaSubject!.shortcut,
            id: '',
            bakaId: bakaSubject!.id,
            timestamp: DateTime.now().toUtc(),
            isDeleted: false,
            order: 0,
          );
    }

    return Lesson(
      change: change,
      room: room,
      teacher: teacher,
      subject: finalSubject,
    );
  }
}
