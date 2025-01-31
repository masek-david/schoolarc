import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_manager/models/homeworks/hw_model.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';
import 'package:school_manager/models/task_model.dart';

class HomeworkDTO extends Task {
  HomeworkDTO({
    required super.subject,
    required super.text,
    required super.deadline,
    required super.isCompleted,
    required super.priority,
    required super.dbIndex,
    required super.description,
    required super.fireId,
    required super.timestamp,
    required super.isDeleted,
    required super.order,
    this.isBeingAnimated = false,
  });

  bool isBeingAnimated = false;

  Homework convert() {
    return Homework(
      fireId: fireId,
      isDeleted: isDeleted,
      subjectDbIndex: subject?.dbIndex,
      text: text,
      deadline: deadline,
      isCompleted: isCompleted,
      priority: priority.index,
      description: description,
      timestamp: timestamp.toDate(),
      order: order,
    );
  }

  @override
  String toString() {
    return 'homework: $text, ${subject?.shortcut}, order: $order, Hive: $dbIndex';
  }

  @override
  HomeworkDTO copyWith({
    SubjectDTO? subject,
    String? text,
    DateTime? deadline,
    bool? isCompleted,
    TaskPriority? priority,
    int? dbIndex,
    String? description,
    String? fireId,
    Timestamp? timestamp,
    bool? isDeleted,
    int? order,
    bool? isBeingAnimated,
  }) {
    return HomeworkDTO(
      subject: subject ?? this.subject,
      text: text ?? this.text,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      dbIndex: dbIndex ?? this.dbIndex,
      description: description ?? this.description,
      fireId: fireId ?? this.fireId,
      timestamp: timestamp ?? this.timestamp,
      isDeleted: isDeleted ?? this.isDeleted,
      order: order ?? this.order,
      isBeingAnimated: isBeingAnimated ?? this.isBeingAnimated,
    );
  }
}
