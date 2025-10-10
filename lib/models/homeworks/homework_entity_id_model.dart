import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/homeworks/hw_entity_model.dart';
import 'package:schoolarc/utils/globals.dart';

class HomeworkEntityWithID extends HomeworkEntity {
  HomeworkEntityWithID({
    required super.date,
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
  HomeworkEntityWithID copyWith({
    String? id,
    Date? date,
    String? text,
    String? description,
    Object? subjectId = noChange,
    int? priority,
    int? order,
    bool? isCompleted,
    bool? isDeleted,
    DateTime? timestamp,
  }) {
    return HomeworkEntityWithID(
      id: id ?? this.id,
      date: date ?? this.date,
      text: text ?? this.text,
      description: description ?? this.description,
      subjectId: subjectId == noChange ? this.subjectId : subjectId as String?,
      priority: priority ?? this.priority,
      order: order ?? this.order,
      isCompleted: isCompleted ?? this.isCompleted,
      isDeleted: isDeleted ?? this.isDeleted,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory HomeworkEntityWithID.fromFireJson(Map<String, dynamic> json) {
    return HomeworkEntityWithID(
      id: json['id'],
      text: json['n'],
      description: json['i'] ?? '',
      subjectId: json['s'],
      // TODO fire
      date: Date.today(),
      // date: DateTime.fromMillisecondsSinceEpoch(json['d']),
      priority: json['p'] ?? 0,
      order: json['o'] ?? 0,
      isCompleted: json['c'] ?? true,
      isDeleted: json['del'] ?? false,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['t']),
    );
  }

  factory HomeworkEntityWithID.fromJson(Map<String, dynamic> json) {
    return HomeworkEntityWithID(
      id: json['id'],
      subjectId: json['subjectId'],
      text: json['text'],
      date: Date.fromDateTime(DateTime.parse(json['date']).toLocal()),
      priority: json['priority'],
      description: json['description'],
      order: json['order'],
      isDeleted: json['isDeleted'],
      isCompleted: json['isCompleted'],
      timestamp: DateTime.tryParse(json['timestamp']) ?? DateTime.now(),
    );
  }
}
