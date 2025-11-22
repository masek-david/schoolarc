import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/exams/exam_data_model.dart';
import 'package:schoolarc/models/homeworks/hw_data_model.dart';
import 'package:schoolarc/utils/globals.dart';

class TaskData {
  final String id;
  final String text;
  final String description;
  final String? subjectId;
  final Date date;
  final int priority;
  final double order;
  final bool isCompleted;
  final bool isDeleted;
  final DateTime timestamp;

  /// stateReaddingVersion changes when the task is re-added, so it doesnt trigger
  /// Multiple widgets use the same globalkey error in AnimatedReorderableListView
  /// it is used in a global key there
  final int stateReaddingVersion;

  TaskData({
    required this.id,
    required this.timestamp,
    required this.isDeleted,
    required this.subjectId,
    required this.text,
    required this.date,
    required this.isCompleted,
    required this.priority,
    required this.description,
    required this.order,
    this.stateReaddingVersion = 0,
  });

  TaskData.empty({Date? deadline})
      : date = deadline ?? Date.today(),
        text = '',
        isCompleted = false,
        priority = 0,
        id = '',
        isDeleted = false,
        order = 0,
        description = '',
        subjectId = null,
        timestamp = DateTime.now().toUtc(),
        stateReaddingVersion = 0;

  HomeworkData toHw() {
    return HomeworkData(
      isDeleted: isDeleted,
      subjectId: subjectId,
      text: text,
      date: date,
      isCompleted: isCompleted,
      priority: priority,
      id: id,
      isBeingAnimated: false,
      stateReaddingVersion: stateReaddingVersion,
      description: description,
      timestamp: timestamp,
      order: order,
    );
  }

  ExamData toExam() {
    return ExamData(
      isDeleted: isDeleted,
      subjectId: subjectId,
      text: text,
      date: date,
      isCompleted: isCompleted,
      priority: priority,
      id: id,
      stateReaddingVersion: stateReaddingVersion,
      description: description,
      timestamp: timestamp,
      order: order,
    );
  }

  TaskData copyWith({
    Object? subjectId = noChange,
    String? text,
    Date? date,
    bool? isCompleted,
    int? priority,
    String? id,
    String? description,
    DateTime? timestamp,
    bool? isDeleted,
    double? order,
    int? stateReaddingVersion,
  }) {
    return TaskData(
      subjectId: subjectId == noChange ? this.subjectId : subjectId as String?,
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
