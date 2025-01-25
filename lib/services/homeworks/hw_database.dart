import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:school_manager/models/homeworks/hw_model.dart';

class HomeworksDatabase {
  final _hwBox = Hive.box('hwBox');
  final _hwSequenceBox = Hive.box('hwOtherData');

  /// returns list of homeworks dbIndexes for each priority
  Map<int, List<int>> getSequence() {
    var map = _hwSequenceBox.get('sequence') ??
        {
          0: <int>[],
          1: <int>[],
          2: <int>[],
          3: <int>[],
        };

    return map.cast<int, List<int>>();
  }

  Future<void> saveSequence(Map<int, List<int>> sequence) async {
    return await _hwSequenceBox.put('sequence', sequence);
  }

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
    _hwSequenceBox.deleteFromDisk();
  }
}
