import 'package:schoolarc/models/homeworks/hw_entity_model.dart';

class HomeworkEntityWithID extends HomeworkEntity {
  HomeworkEntityWithID({
    required super.deadline,
    required super.text,
    required super.description,
    required super.subjectId,
    required super.priority,
    required super.order,
    required super.isCompleted,
    required super.isDeleted,
    required super.timestamp,
    required super.isShared,
    required this.id,
  });

  String id;

  static const _noChange = Object();

  @override
  HomeworkEntityWithID copyWith({
    String? id,
    DateTime? deadline,
    String? text,
    String? description,
    Object? subjectId = _noChange,
    int? priority,
    int? order,
    bool? isCompleted,
    bool? isDeleted,
    DateTime? timestamp,
    bool? isShared,
  }) {
    return HomeworkEntityWithID(
      id: id ?? this.id,
      deadline: deadline ?? this.deadline,
      text: text ?? this.text,
      description: description ?? this.description,
      subjectId: subjectId == _noChange ? this.subjectId : subjectId as String?,
      priority: priority ?? this.priority,
      order: order ?? this.order,
      isCompleted: isCompleted ?? this.isCompleted,
      isDeleted: isDeleted ?? this.isDeleted,
      timestamp: timestamp ?? this.timestamp,
      isShared: isShared ?? this.isShared,
    );
  }

  factory HomeworkEntityWithID.fromFireJson(Map<String, dynamic> json) {
    return HomeworkEntityWithID(
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
      isShared: json['sh'] != null,
    );
  }

  factory HomeworkEntityWithID.fromJson(Map<String, dynamic> json) {
    return HomeworkEntityWithID(
      id: json['id'],
      subjectId: json['subjectId'],
      text: json['text'],
      deadline: DateTime.parse(json['date']),
      priority: json['priority'],
      description: json['description'],
      order: json['order'],
      isDeleted: json['isDeleted'],
      isCompleted: json['isCompleted'],
      isShared: json['isShared'] ?? false,
      // TODO should we same timestamp too?
      timestamp: DateTime.now(),
    );
  }
}
