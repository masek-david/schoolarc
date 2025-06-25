import 'package:hive_ce/hive.dart';

class Log extends HiveObject {
  Log({
    required this.log,
    required this.date,
  });

  String log;
  DateTime date;
}
