import 'package:hive_ce/hive.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/exams/exam_model.dart';
import 'package:schoolarc/models/priority_model.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/utils/globals.dart';

class ExamEntity extends HiveObject {
  ExamEntity({
    required this.isDeleted,
    required this.subjectId,
    required this.text,
    this.description = '',
    required this.date,
    required this.priority,
    required this.timestamp,
    required this.order,
    this.isShared = false,
  });

  final String? subjectId;
  final String text;
  final Date date;
  final int priority;
  final String description;
  final DateTime timestamp;
  final bool isDeleted;
  final int order;
  final bool isShared;

  @override
  String toString() {
    return 'exam: $text, order: $order, deleted: $isDeleted';
  }

  Map<String, dynamic> toJson(String id) {
    return {
      'text': text,
      'subjectId': subjectId,
      'date': date.toString(),
      'priority': priority,
      'description': description,
      'id': id,
      'order': order,
      'isDeleted': isDeleted,
      'isShared': isShared,
      'timestamp':timestamp.toUtc().toIso8601String(),
    };
  }

  ExamEntity copyWith({
    Object? subjectId = noChange,
    String? text,
    Date? date,
    int? priority,
    String? description,
    DateTime? timestamp,
    bool? isDeleted,
    int? order,
    bool? isShared,
  }) {
    return ExamEntity(
      subjectId: subjectId == noChange ? this.subjectId : subjectId as String?,
      text: text ?? this.text,
      date: date ?? this.date,
      priority: priority ?? this.priority,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      isDeleted: isDeleted ?? this.isDeleted,
      order: order ?? this.order,
      isShared: isShared ?? this.isShared,
    );
  }

  Exam convert(String id, Subject? subject) {
    return Exam(
      id: id,
      subject: subject,
      text: text,
      description: description,
      date: date,
      priority: TaskPriority(priority),
      isCompleted: date.isBefore(Date.today()),
      timestamp: timestamp,
      isDeleted: isDeleted,
      order: order,
      isShared: isShared,
    );
  }
}
