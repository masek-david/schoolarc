import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';

class Task {
  Task(
    {
    required this.fireId,
    required this.timestamp,
    required this.isDeleted, 
    required this.subject,
    required this.text,
    required this.deadline,
    required this.completion,
    required this.priority,
    required this.dbIndex,
    required this.description,
  });

  SubjectDTO? subject;
  String text;
  DateTime deadline;
  bool completion;
  TaskPriority priority;
  int dbIndex;
  String? description;
  final String? fireId;
  final Timestamp timestamp;
  final bool isDeleted;
}
