import 'package:hive/hive.dart';
import 'package:school_manager/homeworks/data/hw_model.dart';

class HomeworksDatabase {
  final _hwBox = Hive.box('hwBox');
  final _hwSequenceBox = Hive.box('hwSequenceBox');

  // run this first time ever opening app
  void createInitialData() {
    // _hwBox.deleteFromDisk();
    if (_hwSequenceBox.get('appAlreadyOpened') == null) {
      _hwBox.putAll({
        3: Homework(
            subject: 'Math',
            text: 'This is the assignment of the homework',
            deadline: DateTime.now(),
            isCompleted: false,
            priority: 3),
        2: Homework(
            subject: 'En',
            text: '<- here you can see the subject',
            deadline: DateTime.now(),
            isCompleted: false,
            priority: 2),
        1: Homework(
            subject: 'Pe',
            text: 'and here is the tick box with color indicating priority ->',
            deadline: DateTime.now(),
            isCompleted: false,
            priority: 1),
        0: Homework(
            subject: 'Bio',
            text: 'Prepare presentation',
            deadline: DateTime.now(),
            isCompleted: false,
            priority: 0),
      });

      Map<int, List<int>> sequence = {
        0: [0],
        1: [1],
        2: [2],
        3: [3],
      };
      _hwSequenceBox.put('sequence', sequence);
      _hwSequenceBox.put('appAlreadyOpened', true);
    }
  }

  Map<int, List<int>> getSequence() {
    Map<int, List<int>> converted = {};
    var map = _hwSequenceBox.get('sequence');

    for (var item in map.keys) {
      converted[item] = List<int>.from(map[item]);
    }
    return converted;
  }

  void saveSequence(Map<int, List<int>> sequence) {
    _hwSequenceBox.put('sequence', sequence);
  }

  Map<int, Homework> getDatabase() {
    return _hwBox.toMap().cast<int, Homework>();
  }

  Homework getHomework(int key) {
    return _hwBox.get(key);
  }

  /// returns key of new homework
  Future<int> addHw(Homework hw) async {
    return await _hwBox.add(hw);
  }

  void editHW(int key, Homework hw) {
    _hwBox.put(key, hw);
  }

  void deleteHw(int key) {
    _hwBox.delete(key);
  }

  void changeCompletion(int key) {
    Homework hw = _hwBox.get(key);
    hw.isCompleted = !hw.isCompleted;
  }
}
