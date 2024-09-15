import 'package:school_manager/data/subjects_data/subject_dto_model.dart';

class HomeworkDTO {
  HomeworkDTO({
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
  int priority;
  int dbIndex;
}
