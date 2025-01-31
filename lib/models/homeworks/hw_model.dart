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
    required this.isCompleted,
    required this.priority,
    required this.description,
    required DateTime? timestamp,
    required this.order,
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
  bool isCompleted;
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
  @HiveField(9, defaultValue: 0)
  int order;

  /// saves this as it is now to hive
  void saveSafe() async {
    // i dont know why it works, this box doesnt need to exist, maybe its just the delay?
    await Hive.openBox('subjects');

    if (isInBox) {
      save();
    }
  }

  @override
  String toString() {
    return 'homework: $text, order: $order';
  }

  Homework copyWith({
    int? subjectDbIndex,
    String? text,
    DateTime? deadline,
    bool? isCompleted,
    int? priority,
    int? dbIndex,
    String? description,
    String? fireId,
    DateTime? timestamp,
    bool? isDeleted,
    int? order,
  }) {
    return Homework(
      subjectDbIndex: subjectDbIndex ?? this.subjectDbIndex,
      text: text ?? this.text,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      description: description ?? this.description,
      fireId: fireId ?? this.fireId,
      timestamp: timestamp ?? this.timestamp,
      isDeleted: isDeleted ?? this.isDeleted,
      order: order ?? this.order,
    );
  }

  HomeworkDTO convertToDTO(int dbIndex, SubjectDTO? subject) {
    return HomeworkDTO(
      subject: subject,
      text: text,
      description: description,
      deadline: deadline,
      isCompleted: isCompleted,
      priority: TaskPriority(priority),
      dbIndex: dbIndex,
      fireId: fireId,
      timestamp: Timestamp.fromDate(timestamp),
      isDeleted: isDeleted,
      order: order,
    );
  }
}
