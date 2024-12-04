import 'package:hive/hive.dart';
import 'package:school_manager/models/homeworks/hw_dto_model.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';

part 'hw_model.g.dart';

@HiveType(typeId: 0)
class Homework extends HiveObject {
  Homework({
    required this.subjectDbIndex,
    required this.text,
    required this.deadline,
    required this.completion,
    required this.priority,
    required this.description,
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
  @HiveField(5)
  String? description;

  HomeworkDTO convertToDTO(int dbIndex, SubjectDTO? subject, TaskPriority priority) {
    return HomeworkDTO(
      subject: subject,
      text: text,
      description: description,
      deadline: deadline,
      completion: completion,
      priority: priority,
      dbIndex: dbIndex,
    );
  }
}
