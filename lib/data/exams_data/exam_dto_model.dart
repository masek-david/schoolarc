import 'package:school_manager/data/subjects_data/subject_dto_model.dart';

class ExamDTO {
  ExamDTO(
      {required this.subject,
      required this.text,
      required this.deadline,
      required this.priority,
      required this.dbIndex,
      required this.completion});

  SubjectDTO? subject;
  String text;
  DateTime deadline;
  bool completion;
  int priority;
  int dbIndex;
}
