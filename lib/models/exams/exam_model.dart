
import 'package:hive_ce/hive.dart';
import 'package:school_manager/models/exams/exam_dto_model.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';
import 'package:school_manager/utils/extensions/datetime_extension.dart';

class Exam extends HiveObject {
  Exam({
    required this.isDeleted,
    required this.subjectId,
    required this.text,
    required this.description,
    required this.date,
    required this.priority,
    required this.timestamp,
    required this.order,
  });

  final String? subjectId;
  final String text;
  final DateTime date;
  final int priority;
  final String? description;
  final DateTime timestamp;
  final bool isDeleted;
  final int order;

  @override
  String toString() {
    return 'exam: $text, order: $order, deleted: $isDeleted';
  }

  Map<String, dynamic> toJson(String id) {
    return {
      'text': text,
      'subjectId': subjectId,
      'date': date.toUtc().toIso8601String(),
      'priority': priority,
      'description': description,
      'id': id,
      'order': order,
      'isDeleted': isDeleted,
    };
  }

  // Exam.fromJson(Map<String, dynamic> json)
  //     : subjectId = json['subjectId'],
  //       text = json['text'],
  //       date = DateTime.parse(json['date']),
  //       priority = json['priority'],
  //       description = json['description'],
  //       order = json['order'],
  //       isDeleted = json['isDeleted'],
  //       timestamp = DateTime.now();

  Exam copyWith({
    String? subjectId,
    String? text,
    DateTime? date,
    int? priority,
    String? description,
    DateTime? timestamp,
    bool? isDeleted,
    int? order,
  }) {
    return Exam(
      subjectId: subjectId ?? this.subjectId,
      text: text ?? this.text,
      date: date ?? this.date,
      priority: priority ?? this.priority,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      isDeleted: isDeleted ?? this.isDeleted,
      order: order ?? this.order,
    );
  }

  ExamDTO convertToDTO(String id, SubjectDTO? subject) {
    return ExamDTO(
      id: id,
      subject: subject,
      text: text,
      description: description,
      deadline: date,
      priority: TaskPriority(priority),
      isCompleted: date.isBeforeToday(),
      timestamp: timestamp,
      isDeleted: isDeleted,
      order: order,
    );
  }
}
