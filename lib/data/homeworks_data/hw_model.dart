import 'package:hive/hive.dart';
import 'package:school_manager/data/homeworks_data/hw_dto_model.dart';
import 'package:school_manager/data/subjects_data/subject_dto_model.dart';

part 'hw_model.g.dart';

@HiveType(typeId: 0)
class Homework extends HiveObject {
  Homework({
    required this.subjectDbIndex,
    required this.text,
    required this.deadline,
    required this.completion,
    required this.priority,
  });

  @HiveField(0)
  int? subjectDbIndex;
  @HiveField(1)
  String text;
  @HiveField(2)
  DateTime deadline;
  @HiveField(3)
  bool completion;
  @HiveField(4)
  int priority;

  HomeworkDTO convertToDTO(int dbIndex, SubjectDTO? subject) {
    return HomeworkDTO(
      subject: subject,
      text: text,
      deadline: deadline,
      completion: completion,
      priority: priority,
      dbIndex: dbIndex,
    );
  }
}
