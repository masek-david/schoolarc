import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:school_manager/hive/hive_init.dart';
import 'package:school_manager/models/homeworks/hw_model.dart';

class HomeworksDatabase {
  /// returns map of homeworks with their dbIndexes
  Map<String, Homework> getDatabase() {
    return Hive.box(hwBox).toMap().cast<String, Homework>();
  }

  Homework getHomework(String key) {
    return Hive.box(hwBox).get(key);
  }

  /// adds new homework and returns dbIndex of the new homework
  Future<void> addHw(String id, Homework hw) async {
    return Hive.box(hwBox).put(id, hw.copyWith(deadline: hw.deadline.toUtc()));
  }

  /// puts/replaces homework at dbIndex with new one
  Future<void> editHw(String id, Homework hw) {
    return Hive.box(hwBox).put(id, hw.copyWith(deadline: hw.deadline.toUtc()));
  }

  void deleteHw(String id) {
    Hive.box(hwBox).delete(id);
  }

  void deleteAllFromDisk() {
    Hive.box(hwBox).deleteFromDisk();
  }
}
