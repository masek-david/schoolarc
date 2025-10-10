import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:schoolarc/database/hive/hive_init.dart';
import 'package:schoolarc/models/homeworks/hw_entity_model.dart';

class HomeworksDatabase {
  /// returns map of homeworks with their dbIndexes
  Map<String, HomeworkEntity> getDatabase() {
    return Hive.box(hwBox).toMap().cast<String, HomeworkEntity>();
  }

  HomeworkEntity getHomework(String key) {
    return Hive.box(hwBox).get(key);
  }

  /// adds new homework and returns dbIndex of the new homework
  Future<void> addHw(String id, HomeworkEntity hw) async {
    return Hive.box(hwBox).put(id, hw);
  }

  /// puts/replaces homework at dbIndex with new one
  Future<void> editHw(String id, HomeworkEntity hw) {
    return Hive.box(hwBox).put(id, hw);
  }

  void deleteHw(String id) {
    Hive.box(hwBox).delete(id);
  }

  void deleteAllFromDisk() {
    Hive.box(hwBox).deleteFromDisk();
  }
}
