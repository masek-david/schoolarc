import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:school_manager/models/homeworks/hw_dto_model.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';

part 'hw_model.g.dart';

@HiveType(typeId: 0)
class Homework extends HiveObject {
  Homework({
    required this.fireId,
    required this.isDeleted,
    required this.subjectDbIndex,
    required this.text,
    required this.deadline,
    required this.completion,
    required this.priority,
    required this.description,
    required DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now() {
    if (timestamp == null) {
      saveSafe();
    }
  }

  @HiveField(0)
  int? subjectDbIndex;
  @HiveField(1)
  String text;
  @HiveField(2)
  DateTime deadline;
  @HiveField(3)
  bool completion;
  @HiveField(4)
  int priority;
  @HiveField(5)
  String? description;
  @HiveField(6)
  final String? fireId;
  @HiveField(7)
  DateTime timestamp;
  @HiveField(8, defaultValue: false)
  final bool isDeleted;

  /// saves this as it is now to hive
  void saveSafe() async {
    // i dont know why it works, this box doesnt need to exist, maybe its just the delay?
    await Hive.openBox('subjects');

    if (isInBox) {
      save();
    }
  }

  Homework copyWith({
    int? subjectDbIndex,
    String? text,
    DateTime? deadline,
    bool? completion,
    int? priority,
    int? dbIndex,
    String? description,
    String? fireId,
    DateTime? timestamp,
    bool? isDeleted,
  }) {
    return Homework(
      subjectDbIndex: subjectDbIndex ?? this.subjectDbIndex,
      text: text ?? this.text,
      deadline: deadline ?? this.deadline,
      completion: completion ?? this.completion,
      priority: priority ?? this.priority,
      description: description ?? this.description,
      fireId: fireId ?? this.fireId,
      timestamp: timestamp ?? this.timestamp,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  HomeworkDTO convertToDTO(
      int dbIndex, SubjectDTO? subject, TaskPriority priority) {
    return HomeworkDTO(
      subject: subject,
      text: text,
      description: description,
      deadline: deadline,
      completion: completion,
      priority: priority,
      dbIndex: dbIndex,
      fireId: fireId,
      timestamp: Timestamp.fromDate(timestamp),
      isDeleted: isDeleted,
    );
  }
}
