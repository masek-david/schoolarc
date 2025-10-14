import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/exams/exam_entity_model.dart';
import 'package:schoolarc/models/homeworks/hw_entity_model.dart';
import 'package:schoolarc/models/priority_model.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/utils/extensions/date_extension.dart';
import 'package:schoolarc/utils/extensions/string_extension.dart';
import 'package:schoolarc/utils/globals.dart';

class Task {
  final String id;
  final String text;
  final String description;
  final Subject? subject;
  final Date date;
  final TaskPriority priority;
  final double order;
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
    required this.date,
    required this.isCompleted,
    required this.priority,
    required this.description,
    required this.order,
    this.stateReaddingVersion = 0,
  });

  Task.empty({Date? deadline})
      : date = deadline ?? Date.today(),
        text = '',
        isCompleted = false,
        priority = TaskPriority(0),
        id = '',
        isDeleted = false,
        order = 0,
        description = '',
        subject = null,
        timestamp = DateTime.now().toUtc(),
        stateReaddingVersion = 0;

// TODO try making it external
  HomeworkEntity toHwEntity() {
    return HomeworkEntity(
      isDeleted: isDeleted,
      subjectId: subject?.id,
      text: text,
      date: date,
      isCompleted: isCompleted,
      priority: priority.index,
      description: description,
      timestamp: timestamp,
      order: order,
    );
  }

  ExamEntity toExamEntity() {
    return ExamEntity(
      isDeleted: isDeleted,
      subjectId: subject?.id,
      text: text,
      date: date,
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
      'deadline': date.formatWithText(),
      'isCompleted': isCompleted,
      'priority': priority.index,
      'hasDescription': description != '',
    };
  }

  bool containsText(String text) {
    text = text.withoutDiacriticalMarks.toLowerCase();
    if (this.text.withoutDiacriticalMarks.toLowerCase().contains(text)) {
      return true;
    }
    if (description.withoutDiacriticalMarks.toLowerCase().contains(text)) {
      return true;
    }
    if (subject != null && subject!.containsText(text)) {
      return true;
    }
    return false;
  }

  Task copyWith({
    Object? subject = noChange,
    String? text,
    Date? date,
    bool? isCompleted,
    TaskPriority? priority,
    String? id,
    String? description,
    DateTime? timestamp,
    bool? isDeleted,
    double? order,
    int? stateReaddingVersion,
  }) {
    return Task(
      subject: subject == noChange ? this.subject : subject as Subject?,
      text: text ?? this.text,
      date: date ?? this.date,
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
