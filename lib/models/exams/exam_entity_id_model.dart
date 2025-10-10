import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/exams/exam_entity_model.dart';

class ExamEntityWithID extends ExamEntity {
  ExamEntityWithID({
    required super.text,
    required super.description,
    required super.subjectId,
    required super.date,
    required super.priority,
    required super.order,
    required super.isDeleted,
    required super.timestamp,
    required super.isShared,
    required this.id,
  });

  String id;

  factory ExamEntityWithID.fromFireJson(Map<String, dynamic> json) {
    return ExamEntityWithID(
      id: json['id'],
      text: json['n'],
      description: json['i'] ?? '',
      subjectId: json['s'],
      // TODO fire
      date: Date.today(),
      // date: DateTime.fromMillisecondsSinceEpoch(json['d']),
      priority: json['p'] ?? 0,
      order: json['o'] ?? 0,
      isDeleted: json['del'] ?? false,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['t']),
      isShared: json['sh'] ?? false,
    );
  }

  factory ExamEntityWithID.fromJson(Map<String, dynamic> json) {
    return ExamEntityWithID(
      id: json['id'],
      subjectId: json['subjectId'],
      text: json['text'],
      date: Date.fromDateTime(DateTime.parse(json['date']).toLocal()),
      priority: json['priority'],
      description: json['description'],
      order: json['order'],
      isDeleted: json['isDeleted'],
      timestamp: DateTime.tryParse(json['timestamp']) ?? DateTime.now(),
      isShared: json['isShared'] ?? false,
    );
  }
}
