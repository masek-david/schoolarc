import 'package:hive/hive.dart';
import 'package:school_manager/data/hw_model.dart';

class HomeworksDatabase {
  List<Homework> _hwList = [];

  // reference box
  final _mybox = Hive.box('myBox');

  // run this first time ever opening app
  void createInitialData() {
    _hwList = [];
    _hwList = [
      // [0]subject, [1]text, [2]deadline, [3]completion, [4]priority
      Homework(
          subject: 'ma',
          text: 'tady se zobrazi text',
          deadline: DateTime(2024),
          completion: false,
          priority: 1),
      Homework(
          subject: 'ma',
          text: 'tady se zobrazi text',
          deadline: DateTime(2024),
          completion: false,
          priority: 3),
      Homework(
          subject: 'ma',
          text: 'tady se zobrazi text',
          deadline: DateTime(2024),
          completion: false,
          priority: 0),
      Homework(
          subject: 'cj',
          text: 'uc 23/4',
          deadline: DateTime(2023),
          completion: false,
          priority: 2)
    ];
    updateDatabase();
  }

  // load data from database
  void loadData() {
    _hwList = _mybox.get("HOMEWORKS").cast<Homework>();
  }

  // update data in database
  void updateDatabase() {
    _mybox.put("HOMEWORKS", _hwList);
  }

  List<Homework> getDatabase() {
    return _hwList;
  }

  Homework getHomework(int index) {
    return _hwList[index]; 
  }

  void addHw(Homework hw) {
    _hwList.add(hw);
    updateDatabase();
  }

  void editHW(int index, Homework hw) {
    _hwList[index] = hw;
    updateDatabase();
  }

  void deleteHw(int index) {
    _hwList.removeAt(index);
    updateDatabase();
  }

  void changeCompletion(int index) {
    (_hwList[index]).completion = !(_hwList[index]).completion;
    updateDatabase();
  }
}
