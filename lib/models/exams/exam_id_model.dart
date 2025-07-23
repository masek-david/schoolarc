import 'package:schoolarc/models/exams/exam_entity_model.dart';

class ExamWithID extends ExamEntity {
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
      text: json['n'],
      description: json['i'],
      subjectId: json['s'],
      date: DateTime.fromMillisecondsSinceEpoch(json['d']),
      priority: json['p'] ?? 0,
      order: json['o'] ?? 0,
      isDeleted: json['del'] ?? false,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['t']),
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
