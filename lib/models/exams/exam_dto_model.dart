import 'package:school_manager/models/exams/exam_model.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';
import 'package:school_manager/models/task_model.dart';

class ExamDTO extends Task {
  ExamDTO({
    required super.subject,
    required super.text,
    required super.deadline,
    required super.priority,
    required super.id,
    required super.isCompleted,
    required super.description,
    required super.timestamp,
    required super.isDeleted,
    required super.order,
    super.stateReaddingVersion,
  });

  Exam convert() {
    return Exam(
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

  @override
  String toString() {
    return 'exam: $text, ${subject?.shortcut}, pri: ${priority.htmlIcon} order: $order, Hive, $id, completed: $isCompleted, deleted: $isDeleted';
  }

  Map<String, dynamic> toFireJson() {
    return {
      'n': text,
      't': description,
      's': subject?.id,
      'd': deadline.toIso8601String(),
      'p': priority.index,
      'o': order,
      'del': isDeleted,
      'tm': timestamp.toIso8601String(),
    };
  }

  @override
  ExamDTO copyWith({
    SubjectDTO? subject,
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
    return ExamDTO(
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
