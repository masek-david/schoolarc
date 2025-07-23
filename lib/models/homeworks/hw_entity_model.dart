import 'package:hive_ce/hive.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/models/priority_model.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';

class HomeworkEntity extends HiveObject {
  HomeworkEntity({
    required this.text,
    required this.description,
    required this.subjectId,
    required this.deadline,
    required this.priority,
    required this.order,
    required this.isCompleted,
    required this.isDeleted,
    required this.timestamp,
  });

  final String text;
  final String? description;
  final String? subjectId;
  final DateTime deadline;
  final int priority;
  final int order;
  final bool isCompleted;
  final bool isDeleted;
  final DateTime timestamp;

  @override
  String toString() {
    return 'homework: $text, order: $order, completed: $isCompleted, deleted: $isDeleted';
  }

  Map<String, dynamic> toJson(String id) {
    return {
      'id': id,
      'text': text,
      'subjectId': subjectId,
      'date': deadline.toUtc().toIso8601String(),
      'priority': priority,
      'description': description,
      'order': order,
      'isDeleted': isDeleted,
      'isCompleted': isCompleted,
    };
  }

  HomeworkEntity copyWith({
    String? subjectId,
    String? text,
    DateTime? deadline,
    bool? isCompleted,
    int? priority,
    String? description,
    DateTime? timestamp,
    bool? isDeleted,
    int? order,
  }) {
    return HomeworkEntity(
      subjectId: subjectId ?? this.subjectId,
      text: text ?? this.text,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      isDeleted: isDeleted ?? this.isDeleted,
      order: order ?? this.order,
    );
  }

  Homework convert(String id, Subject? subject) {
    return Homework(
      subject: subject,
      text: text,
      description: description,
      deadline: deadline,
      isCompleted: isCompleted,
      priority: TaskPriority(priority),
      id: id,
      timestamp: timestamp,
      isDeleted: isDeleted,
      order: order,
    );
  }
}
