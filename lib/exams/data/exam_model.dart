import 'package:hive/hive.dart';

part 'exam_model.g.dart';

@HiveType(typeId: 1)
class Exam extends HiveObject {
  Exam({required this.subject, required this.text, required this.date, required this.priority});
  
  @HiveField(0)
  String subject;
  @HiveField(1)
  String text;
  @HiveField(2)
  DateTime date;
  @HiveField(3)
  int priority;
}