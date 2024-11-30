import 'package:school_manager/models/task_model.dart';

class HomeworkDTO extends Task {
  HomeworkDTO({
    required super.subject,
    required super.text,
    required super.deadline,
    required super.completion,
    required super.priority,
    required super.dbIndex,
  });
}
