import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:schoolarc/database/hive/hive_init.dart';
import 'package:schoolarc/models/homeworks/hw_entity_model.dart';

class HomeworksDatabase {
  /// returns map of homeworks with their dbIndexes
  Map<String, HomeworkEntity> readDatabase() {
    return Hive.box(hwBox).toMap().cast<String, HomeworkEntity>();
  }

  HomeworkEntity read(String key) {
    return Hive.box(hwBox).get(key);
  }

  /// puts/replaces homework at dbIndex with new one
  Future<void> put(String id, HomeworkEntity hw) {
    return Hive.box(hwBox).put(id, hw);
  }

  void delete(String id) {
    Hive.box(hwBox).delete(id);
  }

  void deleteBoxFromDisk() {
    Hive.box(hwBox).deleteFromDisk();
  }
}
