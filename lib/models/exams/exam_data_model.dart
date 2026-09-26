import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/exams/exam_entity_model.dart';
import 'package:schoolarc/models/exams/exam_model.dart';
import 'package:schoolarc/models/homeworks/hw_data_model.dart';
import 'package:schoolarc/models/priority_model.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/models/task_data_model.dart';
import 'package:schoolarc/utils/globals.dart';

class ExamData extends TaskData {
  ExamData({
    required super.subjectId,
    required super.text,
    required super.date,
    required super.isCompleted,
    required super.priority,
    required super.id,
    required super.description,
    required super.timestamp,
    required super.isDeleted,
    required super.order,
    super.stateReaddingVersion = 0,
  });

  ExamEntity toEntity() {
    return ExamEntity(
      isDeleted: isDeleted,
      subjectId: subjectId,
      text: text,
      date: date,
      priority: priority,
      description: description,
      timestamp: timestamp,
      order: order,
    );
  }

  @override
  Exam convert(Subject? subject) {
    return Exam(
      isDeleted: isDeleted,
      subject: subject,
      text: text,
      date: date,
      isCompleted: isCompleted,
      priority: TaskPriority(priority),
      description: description,
      timestamp: timestamp,
      order: order,
      id: id,
      stateReaddingVersion: stateReaddingVersion,
    );
  }

  @override
  String toString() {
    return 'exam: $text, $subjectId, pri: $priority order: $order, Hive, $id, completed: $isCompleted, deleted: $isDeleted';
  }

  HomeworkData toHomework() {
    return HomeworkData(
      subjectId: subjectId,
      text: text,
      date: date,
      isCompleted: isCompleted,
      priority: priority,
      id: id,
      description: description,
      timestamp: timestamp,
      isDeleted: isDeleted,
      order: order,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'subjectId': subjectId,
      'date': date.toString(),
      'priority': priority,
      'description': description,
      'id': id,
      'order': order,
      'isDeleted': isDeleted,
      'timestamp': timestamp.toUtc().toIso8601String(),
    };
  }

  factory ExamData.fromJson(Map<String, dynamic> json) {
    late double order;
    if (json['order'] is int) {
      order = (json['order'] as int).toDouble();
    } else {
      order = json['order'];
    }

    return ExamData(
      isCompleted: Date.fromDateTime(
        DateTime.parse(json['date']).toLocal(),
      ).isBefore(Date.today()),
      id: json['id'],
      subjectId: json['subjectId'],
      text: json['text'],
      date: Date.fromDateTime(DateTime.parse(json['date']).toLocal()),
      priority: json['priority'],
      description: json['description'] ?? '',
      order: order,
      isDeleted: json['isDeleted'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFireJson() {
    return {
      'n': text,
      if (description != '') 'i': description,
      if (subjectId != null) 's': subjectId,
      'd': date.toPrimitiveInt(),
      if (priority != 0) 'p': priority,
      if (order != 0) 'o': order,
      if (!isCompleted) 'c': isCompleted,
      if (isDeleted) 'del': isDeleted,
      't': timestamp.millisecondsSinceEpoch,
    };
  }

  factory ExamData.fromFireJson(Map<String, dynamic> json) {
    late Date date;
    if (json['d'] > 920250101) {
      date = Date.fromDateTime(
        DateTime.fromMillisecondsSinceEpoch(json['d']).toLocal(),
      );
    } else {
      date = Date.fromPrimitiveInt(json['d']);
    }

    late double order;
    if (json['o'] is int?) {
      order = (json['o'] as int? ?? 0.1).toDouble();
    } else {
      order = json['o'] ?? 0.1;
    }

    return ExamData(
      id: json['id'],
      text: json['n'],
      description: json['i'] ?? '',
      subjectId: json['s'],
      date: date,
      priority: json['p'] ?? 0,
      order: order,
      isCompleted: json['c'] ?? true,
      isDeleted: json['del'] ?? false,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['t']),
    );
  }

  @override
  ExamData copyWith({
    Object? subjectId = noChange,
    String? text,
    Date? date,
    bool? isCompleted,
    int? priority,
    String? id,
    String? description,
    DateTime? timestamp,
    bool? isDeleted,
    double? order,
    int? stateReaddingVersion,
  }) {
    return ExamData(
      subjectId: subjectId == noChange ? this.subjectId : subjectId as String?,
      text: text ?? this.text,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      id: id ?? this.id,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      isDeleted: isDeleted ?? this.isDeleted,
      order: order ?? this.order,
      stateReaddingVersion: stateReaddingVersion ?? this.stateReaddingVersion,
    );
  }
}
