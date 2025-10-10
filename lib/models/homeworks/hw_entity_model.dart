import 'package:hive_ce/hive.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/models/priority_model.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/utils/globals.dart';

class HomeworkEntity extends HiveObject {
  HomeworkEntity({
    required this.text,
    this.description = '',
    required this.subjectId,
    required this.date,
    required this.priority,
    required this.order,
    required this.isCompleted,
    required this.isDeleted,
    required this.timestamp,
  });

  final String text;
  final String description;
  final String? subjectId;
  final Date date;
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
      'date': date.toString(),
      'priority': priority,
      'description': description,
      'order': order,
      'isDeleted': isDeleted,
      'isCompleted': isCompleted,
      'timestamp': timestamp.toUtc().toIso8601String(),
    };
  }

  HomeworkEntity copyWith({
    Object? subjectId = noChange,
    String? text,
    Date? date,
    bool? isCompleted,
    int? priority,
    String? description,
    DateTime? timestamp,
    bool? isDeleted,
    int? order,
  }) {
    return HomeworkEntity(
      subjectId: subjectId == noChange ? this.subjectId : subjectId as String?,
      text: text ?? this.text,
      date: date ?? this.date,
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
      date: date,
      isCompleted: isCompleted,
      priority: TaskPriority(priority),
      id: id,
      timestamp: timestamp,
      isDeleted: isDeleted,
      order: order,
    );
  }
}
