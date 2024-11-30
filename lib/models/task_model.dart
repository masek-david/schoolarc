import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';

class Task {
  Task({
    required this.subject,
    required this.text,
    required this.deadline,
    required this.completion,
    required this.priority,
    required this.dbIndex,
  });

  SubjectDTO? subject;
  String text;
  DateTime deadline;
  bool completion;
  TaskPriority priority;
  int dbIndex;
}