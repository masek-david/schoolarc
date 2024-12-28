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
    required super.completion,
    required super.description,
    required super.fireId,
    required super.timestamp,
    required super.isDeleted,
  });

    Exam convert() {
    return Exam(
      fireId: fireId,
      isDeleted: isDeleted,
      subjectDbIndex: subject?.dbIndex,
      text: text,
      date: deadline,
      completion: completion,
      priority: priority.index,
      description: description,
      timestamp: timestamp.toDate(),
    );
  }

  ExamDTO copyWith({
    SubjectDTO? subject,
    String? text,
    DateTime? deadline,
    bool? completion,
    TaskPriority? priority,
    int? dbIndex,
    String? description,
    String? fireId,
    Timestamp? timestamp,
    bool? isDeleted,
  }) {
    return ExamDTO(
      subject: subject ?? this.subject,
      text: text ?? this.text,
      deadline: deadline ?? this.deadline,
      completion: completion ?? this.completion,
      priority: priority ?? this.priority,
      dbIndex: dbIndex ?? this.dbIndex,
      description: description ?? this.description,
      fireId: fireId ?? this.fireId,
      timestamp: timestamp ?? this.timestamp,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
