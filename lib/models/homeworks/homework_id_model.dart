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

  @override
  HomeworkWithID copyWith({
    String? id,
    DateTime? deadline,
    String? text,
    String? description,
    String? subjectId,
    int? priority,
    int? order,
    bool? isCompleted,
    bool? isDeleted,
    DateTime? timestamp,
  }) {
    return HomeworkWithID(
      id: id ?? this.id,
      deadline: deadline ?? this.deadline,
      text: text ?? this.text,
      description: description ?? this.description,
      subjectId: subjectId ?? this.subjectId,
      priority: priority ?? this.priority,
      order: order ?? this.order,
      isCompleted: isCompleted ?? this.isCompleted,
      isDeleted: isDeleted ?? this.isDeleted,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory HomeworkWithID.fromFireJson(Map<String, dynamic> json) {
    return HomeworkWithID(
      id: json['id'],
      text: json['n'],
      description: json['i'],
      subjectId: json['s'],
      deadline: DateTime.fromMillisecondsSinceEpoch(json['d']),
      priority: json['p'] ?? 0,
      order: json['o'] ?? 0,
      isCompleted: json['c'] ?? true,
      isDeleted: json['del'] ?? false,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['t']),
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
