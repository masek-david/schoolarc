import 'package:hive_ce/hive.dart';
import 'package:schoolarc/database/hive/hive_init.dart';
import 'package:schoolarc/models/logs/log_model.dart';

class LogsService {
  void save(String log) async {
    final box = await Hive.openBox(logBox);
    box.add(Log(log: log, date: DateTime.now()));
  }

  void delete(int key) async {
    final box = await Hive.openBox(logBox);
    box.delete(key);
  }

  void deleteAll() async {
    final box = await Hive.openBox(logBox);
    box.deleteAll(box.keys);
  }

  Map<int, Log> getAllLogs() {
    final box = Hive.box(logBox);
    return box.toMap().cast<int, Log>();
  }
}
