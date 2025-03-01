import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_manager/models/homeworks/hw_dto_model.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';
import 'package:school_manager/models/task_model.dart';

class BakaHomework extends Task {
  BakaHomework({
    required super.isCompleted,
    required super.dbIndex,
    required super.deadline,
    required super.description,
    required super.priority,
    required super.subject,
    required super.text,
    required this.alreadyAdded,
    required this.alreadySeen,
    required this.bakaId,
    required super.fireId,
    required super.timestamp,
    required super.isDeleted,
    required super.order,
  });

  final String bakaId;
  bool alreadyAdded;
  final bool alreadySeen;

  HomeworkDTO toHwDTO() {
    return HomeworkDTO(
        subject: subject,
        text: text,
        deadline: deadline,
        isCompleted: isCompleted,
        priority: priority,
        dbIndex: dbIndex,
        description: description,
        fireId: fireId,
        timestamp: timestamp,
        isDeleted: isDeleted,
        order: order);
  }

  @override
  BakaHomework copyWith({
    bool? isCompleted,
    int? dbIndex,
    DateTime? deadline,
    String? description,
    TaskPriority? priority,
    SubjectDTO? subject,
    String? text,
    bool? alreadyAdded,
    bool? alreadySeen,
    String? bakaId,
    String? fireId,
    Timestamp? timestamp,
    bool? isDeleted,
    int? order,
  }) {
    return BakaHomework(
      isCompleted: isCompleted ?? this.isCompleted,
      dbIndex: dbIndex ?? this.dbIndex,
      deadline: deadline ?? this.deadline,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      subject: subject ?? this.subject,
      text: text ?? this.text,
      alreadyAdded: alreadyAdded ?? this.alreadyAdded,
      alreadySeen: alreadySeen ?? this.alreadySeen,
      bakaId: bakaId ?? this.bakaId,
      fireId: fireId ?? this.fireId,
      timestamp: timestamp ?? this.timestamp,
      isDeleted: isDeleted ?? this.isDeleted,
      order: order ?? this.order,
    );
  }
}
