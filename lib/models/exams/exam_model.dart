import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/exams/exam_data_model.dart';
import 'package:schoolarc/models/exams/exam_entity_model.dart';
import 'package:schoolarc/models/priority_model.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/models/task_model.dart';
import 'package:schoolarc/utils/globals.dart';

class Exam extends Task {
  Exam({
    required super.subject,
    required super.text,
    required super.date,
    required super.priority,
    required super.id,
    required super.isCompleted,
    required super.description,
    required super.timestamp,
    required super.isDeleted,
    required super.order,
    super.stateReaddingVersion,
  });

  ExamEntity toEntity() {
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

  ExamData toData() {
    return ExamData(
      stateReaddingVersion: stateReaddingVersion,
      id: id,
      isCompleted: date.isBefore(Date.today()),
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

  @override
  String toString() {
    return 'exam: $text, ${subject?.shortcut}, pri: ${priority.htmlIcon} order: $order, Hive, $id, completed: $isCompleted, deleted: $isDeleted';
  }

  @override
  Exam copyWith({
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
    return Exam(
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
