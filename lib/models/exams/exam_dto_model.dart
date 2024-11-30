import 'package:school_manager/models/task_model.dart';

class ExamDTO extends Task {
  ExamDTO({
    required super.subject,
    required super.text,
    required super.deadline,
    required super.priority,
    required super.dbIndex,
    required super.completion,
  });
}
