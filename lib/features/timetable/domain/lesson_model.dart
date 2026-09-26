import 'package:schoolarc/features/timetable/domain/lesson_change_model.dart';
import 'package:schoolarc/features/timetable/domain/lesson_entity_model.dart';
import 'package:schoolarc/features/timetable/domain/teacher_model.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';

class Lesson {
  Lesson({
    this.subject,
    this.change,
    this.teacher,
    this.room,
  });

  const Lesson.empty()
    : subject = null,
      change = null,
      room = null,
      teacher = null;

  final Subject? subject;
  final LessonChange? change;
  final String? room;
  final Teacher? teacher;

  bool get isEmpty {
    return subject == null && change == null && teacher == null && room == null;
  }

  LessonEntity toEntity() {
    return LessonEntity(subjectId: subject?.id, teacher: teacher, room: room);
  }
}
