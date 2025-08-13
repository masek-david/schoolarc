import 'package:schoolarc/models/homeworks/hw_entity_model.dart';
import 'package:schoolarc/models/priority_model.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/models/task_model.dart';

class Homework extends Task {
  Homework({
    required super.subject,
    required super.text,
    required super.deadline,
    required super.isCompleted,
    required super.priority,
    required super.id,
    required super.description,
    required super.timestamp,
    required super.isDeleted,
    required super.order,
    required super.isShared,
    super.stateReaddingVersion = 0,
    this.isBeingAnimated = false,
  });

  bool isBeingAnimated;

  HomeworkEntity convert() {
    return HomeworkEntity(
      isDeleted: isDeleted,
      subjectId: subject?.id,
      text: text,
      deadline: deadline,
      isCompleted: isCompleted,
      priority: priority.index,
      description: description,
      timestamp: timestamp,
      order: order,
      isShared: isShared,
    );
  }

  @override
  String toString() {
    return 'homework: $text, ${subject?.shortcut}, pri: ${priority.htmlIcon} order: $order, Hive, $id, completed: $isCompleted, deleted: $isDeleted';
  }

  Map<String, dynamic> toFireJson() {
    return {
      'n': text,
      if (description != null && description != '') 'i': description,
      if (subject != null) 's': subject?.id,
      'd': deadline.millisecondsSinceEpoch,
      if (priority.index != 0) 'p': priority.index,
      if (order != 0) 'o': order,
      if (!isCompleted) 'c': isCompleted,
      if (isDeleted) 'del': isDeleted,
      't': timestamp.millisecondsSinceEpoch,
      if (isShared) 'sh': deadline.millisecondsSinceEpoch + 2.592e+8,
    };
  }

  @override
  Homework copyWith({
    Subject? subject,
    String? text,
    DateTime? deadline,
    bool? isCompleted,
    TaskPriority? priority,
    String? id,
    String? description,
    String? fireId,
    DateTime? timestamp,
    bool? isDeleted,
    int? order,
    bool? isShared,
    bool? isBeingAnimated,
    int? stateReaddingVersion,
  }) {
    return Homework(
      subject: subject ?? this.subject,
      text: text ?? this.text,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      id: id ?? this.id,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      isDeleted: isDeleted ?? this.isDeleted,
      order: order ?? this.order,
      isShared: isShared ?? this.isShared,
      isBeingAnimated: isBeingAnimated ?? this.isBeingAnimated,
      stateReaddingVersion: stateReaddingVersion ?? this.stateReaddingVersion,
    );
  }
}
