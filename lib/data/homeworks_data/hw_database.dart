import 'package:hive/hive.dart';
import 'package:school_manager/data/homeworks_data/hw_model.dart';

class HomeworksDatabase {
  final _hwBox = Hive.box('hwBox');
  final _hwSequenceBox = Hive.box('hwOtherData');

  /// initial data will be inserted
  void createInitialData() {
    _hwBox.putAll({
      3: Homework(
          subject: 'Math',
          text: 'This is the assignment of the homework',
          deadline: DateTime.now(),
          completion: false,
          priority: 3),
      2: Homework(
          subject: 'En',
          text: '<- here you can see the subject',
          deadline: DateTime.now(),
          completion: false,
          priority: 2),
      1: Homework(
          subject: 'Pe',
          text: 'and here is the tick box with color indicating priority ->',
          deadline: DateTime.now(),
          completion: false,
          priority: 1),
      0: Homework(
          subject: 'Bio',
          text: 'Prepare presentation',
          deadline: DateTime.now(),
          completion: false,
          priority: 0),
    });

    Map<int, List<int>> sequence = {
      0: [0],
      1: [1],
      2: [2],
      3: [3],
    };
    _hwSequenceBox.put('sequence', sequence);
  }

  /// returns list of homeworks dbIndexes for each priority
  Map<int, List<int>> getSequence() {
    return Map.from(_hwSequenceBox.get('sequence'));
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
  void editHw(int dbIndex, Homework hw) {
    _hwBox.put(dbIndex, hw);
  }

  void deleteHw(int dbIndex) {
    _hwBox.delete(dbIndex);
  }

  void changeCompletion(int dbIndex, bool value) {
    Homework hw = _hwBox.get(dbIndex);

    _hwBox.put(
      dbIndex,
      Homework(
        subject: hw.subject,
        text: hw.text,
        deadline: hw.deadline,
        completion: value,
        priority: hw.priority,
      ),
    );
  }
}
