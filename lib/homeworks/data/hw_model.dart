import 'package:hive/hive.dart';

part 'hw_model.g.dart';

@HiveType(typeId: 0)
class Homework extends HiveObject {
  Homework({required this.subject, required this.text, required this.deadline, required this.isCompleted, required this.priority});
  
  @HiveField(0)
  String subject;
  @HiveField(1)
  String text;
  @HiveField(2)
  DateTime deadline;
  @HiveField(3)
  bool isCompleted;
  @HiveField(4)
  int priority;
}