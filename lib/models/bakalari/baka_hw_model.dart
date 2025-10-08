import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/models/priority_model.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/models/task_model.dart';
import 'package:schoolarc/utils/globals.dart';

class BakaHomework extends Task {
  BakaHomework({
    required super.isCompleted,
    required super.id,
    required super.date,
    required super.description,
    required super.priority,
    required super.subject,
    required super.text,
    required this.alreadyAdded,
    required this.alreadySeen,
    required this.bakaId,
    required super.timestamp,
    required super.isDeleted,
    required super.order,
    required super.isShared,
    super.stateReaddingVersion,
  });

  final String bakaId;
  final bool alreadyAdded;
  final bool alreadySeen;

  Homework toHw() {
    return Homework(
      subject: subject,
      text: text,
      date: date,
      isCompleted: isCompleted,
      priority: priority,
      id: id,
      description: description,
      timestamp: timestamp,
      isDeleted: isDeleted,
      order: order,
      isShared: isShared,
    );
  }

  @override
  BakaHomework copyWith({
    bool? isCompleted,
    String? id,
    Date? date,
    String? description,
    TaskPriority? priority,
    Object? subject = noChange,
    String? text,
    String? fireId,
    DateTime? timestamp,
    bool? isDeleted,
    int? order,
    int? stateReaddingVersion,
    bool? alreadyAdded,
    bool? alreadySeen,
    String? bakaId,
    bool? isShared,
  }) {
    return BakaHomework(
      isCompleted: isCompleted ?? this.isCompleted,
      id: id ?? this.id,
      date: date ?? this.date,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      subject: subject == noChange ? this.subject : subject as Subject?,
      text: text ?? this.text,
      alreadyAdded: alreadyAdded ?? this.alreadyAdded,
      alreadySeen: alreadySeen ?? this.alreadySeen,
      bakaId: bakaId ?? this.bakaId,
      timestamp: timestamp ?? this.timestamp,
      isDeleted: isDeleted ?? this.isDeleted,
      order: order ?? this.order,
      isShared: isShared ?? this.isShared,
      stateReaddingVersion: stateReaddingVersion ?? this.stateReaddingVersion,
    );
  }
}
