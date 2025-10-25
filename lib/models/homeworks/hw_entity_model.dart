import 'package:hive_ce/hive.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/homeworks/hw_data_model.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/models/priority_model.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/utils/globals.dart';

class HomeworkEntity extends HiveObject {
  HomeworkEntity({
    required this.text,
    // Its not requiered, because when loading from hive, it could be Null (thats how it used to be)
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
  final double order;
  final bool isCompleted;
  final bool isDeleted;
  final DateTime timestamp;

  @override
  String toString() {
    return 'homework: $text, order: $order, completed: $isCompleted, deleted: $isDeleted';
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

  HomeworkData toData(String id) {
    return HomeworkData(
      subjectId: subjectId,
      text: text,
      date: date,
      isCompleted: isCompleted,
      priority: priority,
      id: id,
      description: description,
      timestamp: timestamp,
      isDeleted: isDeleted,
      order: order,
    );
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
    double? order,
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
}
