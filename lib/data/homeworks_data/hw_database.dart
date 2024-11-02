import 'package:hive/hive.dart';
import 'package:school_manager/data/homeworks_data/hw_model.dart';

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

  void saveSequence(Map<int, List<int>> sequence) {
    _hwSequenceBox.put('sequence', sequence);
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
  Future<void> editHw(int dbIndex, Homework hw) async {
    await _hwBox.put(dbIndex, hw);
    return;
  }

  void deleteHw(int dbIndex) {
    _hwBox.delete(dbIndex);
  }

  void changeCompletion(int dbIndex, bool value) {
    Homework hw = _hwBox.get(dbIndex);

    _hwBox.put(
      dbIndex,
      Homework(
        subjectDbIndex: hw.subjectDbIndex,
        text: hw.text,
        deadline: hw.deadline,
        completion: value,
        priority: hw.priority,
      ),
    );
  }
}
