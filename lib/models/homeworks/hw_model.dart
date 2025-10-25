import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/homeworks/hw_data_model.dart';
import 'package:schoolarc/models/homeworks/hw_entity_model.dart';
import 'package:schoolarc/models/priority_model.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/models/task_model.dart';
import 'package:schoolarc/utils/globals.dart';

class Homework extends Task {
  Homework({
    required super.subject,
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
    this.isBeingAnimated = false,
  });

  /// True when the checkbox animation is running
  bool isBeingAnimated;

  HomeworkEntity convert() {
    return HomeworkEntity(
      isDeleted: isDeleted,
      subjectId: subject?.id,
      text: text,
      date: date,
      isCompleted: isCompleted,
      priority: priority.index,
      description: description,
      timestamp: timestamp,
      order: order,
    );
  }

  HomeworkData toData() {
    return HomeworkData(
      isBeingAnimated: isBeingAnimated,
      stateReaddingVersion: stateReaddingVersion,
      id: id,
      isCompleted: date.isBefore(Date.today()),
      isDeleted: isDeleted,
      subjectId: subject?.id,
      text: text,
      date: date,
      priority: priority.index,
      description: description,
      timestamp: timestamp,
      order: order,
    );
  }

  @override
  String toString() {
    return 'homework: $text, ${subject?.shortcut}, pri: ${priority.htmlIcon} order: $order, Hive, $id, completed: $isCompleted, deleted: $isDeleted';
  }

  @override
  Homework copyWith({
    Object? subject = noChange,
    String? text,
    Date? date,
    bool? isCompleted,
    TaskPriority? priority,
    String? id,
    String? description,
    String? fireId,
    DateTime? timestamp,
    bool? isDeleted,
    double? order,
    bool? isBeingAnimated,
    int? stateReaddingVersion,
  }) {
    return Homework(
      subject: subject == noChange ? this.subject : subject as Subject?,
      text: text ?? this.text,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      id: id ?? this.id,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      isDeleted: isDeleted ?? this.isDeleted,
      order: order ?? this.order,
      isBeingAnimated: isBeingAnimated ?? this.isBeingAnimated,
      stateReaddingVersion: stateReaddingVersion ?? this.stateReaddingVersion,
    );
  }
}
