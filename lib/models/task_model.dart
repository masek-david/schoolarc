import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_manager/models/exams/exam_model.dart';
import 'package:school_manager/models/homeworks/hw_model.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';
import 'package:school_manager/utils/extensions/datetime_extension.dart';
import 'package:school_manager/utils/extensions/string_extension.dart';

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

  /// stateReaddingVersion changes when the task is re-added, so it doesnt trigger
  /// Multiple widgets use the same globalkey error in AnimatedReorderableListView
  /// it is used in a global key there
  final int stateReaddingVersion;

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
    this.stateReaddingVersion = 0,
  });

  Task.empty({DateTime? deadline})
      : deadline = deadline ?? DateTime.now(),
        text = '',
        fireId = null,
        isCompleted = false,
        priority = TaskPriority(0),
        dbIndex = 0,
        isDeleted = false,
        order = 0,
        timestamp = Timestamp.now(),
        stateReaddingVersion = 0;

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

  Map<String, dynamic> toWidgetJson() {
    return {
      'dbIndex': dbIndex,
      'text': text,
      'subject': subject?.shortcut ?? '',
      'deadline': deadline.dateText(),
      'isCompleted': isCompleted,
      'priority': priority.index,
      'hasDescription': description != null,
    };
  }

  bool containsText(String text) {
    text = text.withoutDiacriticalMarks.toLowerCase();
    if (this.text.withoutDiacriticalMarks.toLowerCase().contains(text)) {
      return true;
    }
    if (description != null &&
        description!.withoutDiacriticalMarks.toLowerCase().contains(text)) {
      return true;
    }
    if (subject != null && subject!.containsText(text)) {
      return true;
    }
    return false;
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
    int? stateReaddingVersion,
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
      stateReaddingVersion: stateReaddingVersion ?? this.stateReaddingVersion,
    );
  }
}
