import 'package:school_manager/models/exams/exam_entity_model.dart';
import 'package:school_manager/models/homeworks/hw_entity_model.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/models/subjects/subject_model.dart';
import 'package:school_manager/utils/extensions/datetime_extension.dart';
import 'package:school_manager/utils/extensions/string_extension.dart';

class Task {
  final String id;
  final String text;
  final String? description;
  final Subject? subject;
  final DateTime deadline;
  final TaskPriority priority;
  final int order;
  final bool isCompleted;
  final bool isDeleted;
  final DateTime timestamp;

  /// stateReaddingVersion changes when the task is re-added, so it doesnt trigger
  /// Multiple widgets use the same globalkey error in AnimatedReorderableListView
  /// it is used in a global key there
  final int stateReaddingVersion;

  Task({
    required this.id,
    required this.timestamp,
    required this.isDeleted,
    required this.subject,
    required this.text,
    required this.deadline,
    required this.isCompleted,
    required this.priority,
    required this.description,
    required this.order,
    this.stateReaddingVersion = 0,
  });

  Task.empty({DateTime? deadline})
      : deadline = deadline ?? DateTime.now(),
        text = '',
        isCompleted = false,
        priority = TaskPriority(0),
        id = '',
        isDeleted = false,
        order = 0,
        description = null,
        subject = null,
        timestamp = DateTime.now().toUtc(),
        stateReaddingVersion = 0;

  HomeworkEntity toHw() {
    return HomeworkEntity(
      // id: id,
      isDeleted: isDeleted,
      subjectId: subject?.id,
      text: text,
      deadline: deadline,
      isCompleted: isCompleted,
      priority: priority.index,
      description: description,
      timestamp: timestamp,
      order: order,
    );
  }

  ExamEntity toExam() {
    return ExamEntity(
      isDeleted: isDeleted,
      subjectId: subject?.id,
      text: text,
      date: deadline,
      priority: priority.index,
      description: description,
      timestamp: timestamp,
      order: order,
    );
  }

  Map<String, dynamic> toWidgetJson() {
    return {
      'id': id,
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
    Subject? subject,
    String? text,
    DateTime? deadline,
    bool? isCompleted,
    TaskPriority? priority,
    String? id,
    String? description,
    DateTime? timestamp,
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
      id: id ?? this.id,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      isDeleted: isDeleted ?? this.isDeleted,
      order: order ?? this.order,
      stateReaddingVersion: stateReaddingVersion ?? this.stateReaddingVersion,
    );
  }
}
