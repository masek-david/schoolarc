import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:school_manager/models/exams/exam_dto_model.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';

part 'exam_model.g.dart';

@HiveType(typeId: 1)
class Exam extends HiveObject {
  Exam({
    required this.fireId,
    required this.isDeleted,
    required this.subjectDbIndex,
    required this.text,
    required this.description,
    required this.date,
    required this.priority,
    required this.completion,
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
  DateTime date;
  @HiveField(3)
  int priority;
  @HiveField(4)
  bool completion;
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

  ExamDTO convertToDTO(
      int dbIndex, SubjectDTO? subject, TaskPriority priority) {
    return ExamDTO(
      subject: subject,
      text: text,
      description: description,
      deadline: date,
      priority: priority,
      dbIndex: dbIndex,
      completion: completion,
      fireId: fireId,
      timestamp: Timestamp.fromDate(timestamp),
      isDeleted: isDeleted,
    );
  }
}
