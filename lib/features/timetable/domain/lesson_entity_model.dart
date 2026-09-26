import 'package:schoolarc/features/timetable/domain/teacher_model.dart';

class LessonEntity {
  const LessonEntity({
    required this.subjectId,
    required this.teacher,
    required this.room,
  });

  const LessonEntity.empty() : subjectId = null, room = null, teacher = null;

  final String? subjectId;
  final Teacher? teacher;
  final String? room;
}
