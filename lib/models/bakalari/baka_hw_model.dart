
import 'package:school_manager/models/homeworks/hw_dto_model.dart';
import 'package:school_manager/models/task_model.dart';

class BakaHomework extends Task {
  BakaHomework({
    required super.isCompleted,
    required super.dbIndex,
    required super.deadline,
    required super.description,
    required super.priority,
    required super.subject,
    required super.text,
    required this.alreadyAdded,
    required this.alreadySeen,
    required this.bakaId,
    required super.fireId,
    required super.timestamp,
    required super.isDeleted,
    required super.order,
  });

  final String bakaId;
  bool alreadyAdded;
  final bool alreadySeen;

  HomeworkDTO toHwDTO() {
    return HomeworkDTO(
        subject: subject,
        text: text,
        deadline: deadline,
        isCompleted: isCompleted,
        priority: priority,
        dbIndex: dbIndex,
        description: description,
        fireId: fireId,
        timestamp: timestamp,
        isDeleted: isDeleted,
        order: order);
  }
}