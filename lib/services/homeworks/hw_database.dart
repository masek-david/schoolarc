import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:school_manager/models/homeworks/hw_model.dart';

class HomeworksDatabase {
  final _hwBox = Hive.box('hwBox');

  /// returns map of homeworks with their dbIndexes
  Map<int, Homework> getDatabase() {
    return _hwBox.toMap().cast<int, Homework>();
  }

  Homework getHomework(int dbIndex) {
    return _hwBox.get(dbIndex);
  }

  /// adds new homework and returns dbIndex of the new homework
  Future<int> addHw(Homework hw) async {
    return await _hwBox.add(hw);
  }

  /// puts/replaces homework at dbIndex with new one
  Future<void> editHw(int dbIndex, Homework hw) {
    return _hwBox.put(dbIndex, hw);
  }

  void deleteHw(int dbIndex) {
    _hwBox.delete(dbIndex);
  }

  void deleteAllFromDisk(){
    _hwBox.deleteFromDisk();
  }
}
