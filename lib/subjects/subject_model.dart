import 'package:hive/hive.dart';

part 'subject_model.g.dart';

@HiveType(typeId: 2)
class Subject extends HiveObject{
  Subject({required this.name, required this.shortcut});
  
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String shortcut;
}