import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_manager/models/exams/exam_model.dart';
import 'package:school_manager/models/homeworks/hw_model.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';

class Task {
  SubjectDTO? subject;
  String text;
  DateTime deadline;
  bool isCompleted;
  TaskPriority priority;
  int dbIndex;
  String? description;
  final String? fireId;
  final Timestamp timestamp;
  final bool isDeleted;
  int order;

  Task({
    required this.fireId,
    required this.timestamp,
    required this.isDeleted,
    required this.subject,
    required this.text,
    required this.deadline,
    required this.isCompleted,
    required this.priority,
    required this.dbIndex,
    required this.description,
    required this.order,
  });

  Task.empty({DateTime? deadline})
      : deadline = deadline ??  DateTime.now(),
        text = '',
        fireId = null,
        isCompleted = false,
        priority = TaskPriority(0),
        dbIndex = 0,
        isDeleted = false,
        order = 0,
        timestamp = Timestamp.now();

  Homework toHw() {
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

  Exam toExam() {
    return Exam(
      fireId: fireId,
      isDeleted: isDeleted,
      subjectDbIndex: subject?.dbIndex,
      text: text,
      date: deadline,
      priority: priority.index,
      description: description,
      timestamp: timestamp.toDate(),
      order: order,
    );
  }

  Task copyWith({
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
  }) {
    return Task(
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
    );
  }
}
