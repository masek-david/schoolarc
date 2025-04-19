import 'package:school_manager/models/homeworks/hw_entity_model.dart';

class HomeworkWithID extends HomeworkEntity {
  HomeworkWithID({
    required super.deadline,
    required super.text,
    required super.description,
    required super.subjectId,
    required super.priority,
    required super.order,
    required super.isCompleted,
    required super.isDeleted,
    required super.timestamp,
    required this.id,
  });

  String id;

  factory HomeworkWithID.fromFireJson(Map<String, dynamic> json) {
    return HomeworkWithID(
      id: json['id'],
      subjectId: json['s'],
      text: json['n'],
      deadline: DateTime.parse(json['d']),
      priority: json['p'],
      description: json['t'],
      order: json['o'],
      isDeleted: json['del'],
      isCompleted: json['c'],
      timestamp: DateTime.parse(json['tm']),
    );
  }

  factory HomeworkWithID.fromJson(Map<String, dynamic> json) {
    return HomeworkWithID(
      id: json['id'],
      subjectId: json['subjectId'],
      text: json['text'],
      deadline: DateTime.parse(json['date']),
      priority: json['priority'],
      description: json['description'],
      order: json['order'],
      isDeleted: json['isDeleted'],
      isCompleted: json['isCompleted'],
      timestamp: DateTime.now(),
    );
  }
}
