import 'package:hive/hive.dart';
import 'package:school_manager/models/logs/log_model.dart';

class LogsService {
  final box = Hive.box('logBox');

  void save(String log) async {
    box.add(Log(log: log, date: DateTime.now()));
  }

  void delete(int key) async {
    box.delete(key);
  }

  void deleteAll(){
    box.deleteAll(box.keys);
  }

  Map<int, Log> getAllLogs() {
    return box.toMap().cast<int, Log>();
  }
}
