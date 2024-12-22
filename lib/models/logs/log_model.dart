import 'package:hive/hive.dart';

part 'log_model.g.dart';

@HiveType(typeId: 5)
class Log extends HiveObject {
  Log({
    required this.log,
    required this.date,
  });

  @HiveField(0)
  String log;
  @HiveField(1)
  DateTime date;
}
