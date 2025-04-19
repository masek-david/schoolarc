import 'package:school_manager/models/exams/exam_model.dart';

class ExamWithID extends Exam {
  ExamWithID({
    required super.text,
    required super.description,
    required super.subjectId,
    required super.date,
    required super.priority,
    required super.order,
    required super.isDeleted,
    required super.timestamp,
    required this.id,
  });

  String id;

  factory ExamWithID.fromFireJson(Map<String, dynamic> json) {
    return ExamWithID(
      id: json['id'],
      subjectId: json['s'],
      text: json['n'],
      date: DateTime.parse(json['d']),
      priority: json['p'],
      description: json['t'],
      order: json['o'],
      isDeleted: json['del'],
      timestamp: DateTime.parse(json['tm']),
    );
  }

  factory ExamWithID.fromJson(Map<String, dynamic> json) {
    return ExamWithID(
      id: json['id'],
      subjectId: json['subjectId'],
      text: json['text'],
      date: DateTime.parse(json['date']),
      priority: json['priority'],
      description: json['description'],
      order: json['order'],
      isDeleted: json['isDeleted'],
      timestamp: DateTime.now(),
    );
  }
}
