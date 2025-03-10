import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:school_manager/models/homeworks/hw_model.dart';

class HomeworksDatabase {
  /// returns map of homeworks with their dbIndexes
  Map<int, Homework> getDatabase() {
    return Hive.box('hwBox').toMap().cast<int, Homework>();
  }

  Homework getHomework(int dbIndex) {
    return Hive.box('hwBox').get(dbIndex);
  }

  /// adds new homework and returns dbIndex of the new homework
  Future<int> addHw(Homework hw) async {
    return await Hive.box('hwBox').add(hw);
  }

  /// puts/replaces homework at dbIndex with new one
  Future<void> editHw(int dbIndex, Homework hw) {
    return Hive.box('hwBox').put(dbIndex, hw);
  }

  void deleteHw(int dbIndex) {
    Hive.box('hwBox').delete(dbIndex);
  }

  void deleteAllFromDisk(){
    Hive.box('hwBox').deleteFromDisk();
  }
}
