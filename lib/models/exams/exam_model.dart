import 'package:hive/hive.dart';
import 'package:school_manager/models/exams/exam_dto_model.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';

part 'exam_model.g.dart';

@HiveType(typeId: 1)
class Exam extends HiveObject {
  Exam({
    required this.subjectDbIndex,
    required this.text,
    required this.date,
    required this.priority,
    required this.completion,
  });

  @HiveField(0)
  int? subjectDbIndex;
  @HiveField(1)
  String text;
  @HiveField(2)
  DateTime date;
  @HiveField(3)
  int priority;
  @HiveField(4)
  bool completion;

  ExamDTO convertToDTO(int dbIndex, SubjectDTO? subject, TaskPriority priority) {
    return ExamDTO(
      subject: subject,
      text: text,
      deadline: date,
      priority: priority,
      dbIndex: dbIndex,
      completion: completion,
    );
  }
}
