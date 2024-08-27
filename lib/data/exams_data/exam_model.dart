import 'package:hive/hive.dart';
import 'package:school_manager/data/exams_data/exam_dto_model.dart';

part 'exam_model.g.dart';

@HiveType(typeId: 1)
class Exam extends HiveObject {
  Exam({
    required this.subject,
    required this.text,
    required this.date,
    required this.priority,
    required this.completion,
  });

  @HiveField(0)
  String subject;
  @HiveField(1)
  String text;
  @HiveField(2)
  DateTime date;
  @HiveField(3)
  int priority;
  @HiveField(4)
  bool completion;

  ExamDTO convertToDTO(int dbIndex) {
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
