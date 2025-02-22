import 'package:cloud_firestore/cloud_firestore.dart';
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
    required super.dbIndex,
    required super.isCompleted,
    required super.description,
    required super.fireId,
    required super.timestamp,
    required super.isDeleted,
    required super.order,
  });

  Exam convert() {
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

  @override
  String toString() {
    return 'exam: $text, ${subject?.shortcut}, order: $order, Hive, $dbIndex, completed: $isCompleted, deleted: $isDeleted';
  }

  @override
  ExamDTO copyWith({
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
    return ExamDTO(
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
