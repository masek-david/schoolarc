import 'package:hive/hive.dart';
import 'package:school_manager/data/hw_model.dart';
import 'package:school_manager/data/hw_dto_model.dart';

class HomeworksDatabase {
  List<Homework> _hwList = [];
  // int index = 0;

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

  // returns list of homeworks DTOs, with indexes
  List<HomeworkDTO> getDatabase() {
    List<HomeworkDTO> indexedList = [];

    for (int index = 0; index < _hwList.length; index++) {
      Homework hw = _hwList[index];
      indexedList.add(HomeworkDTO(
          subject: hw.subject,
          text: hw.text,
          deadline: hw.deadline,
          completion: hw.completion,
          priority: hw.priority,
          index: index));
    }
    return indexedList;
  }

  HomeworkDTO getHomework(int index) {
    Homework hw = _hwList[index];
      return HomeworkDTO(
          subject: hw.subject,
          text: hw.text,
          deadline: hw.deadline,
          completion: hw.completion,
          priority: hw.priority,
          index: index);
  }

  HomeworkDTO addHw(Homework hw) {
    _hwList.add(hw);
    updateDatabase();
    return HomeworkDTO(
      subject: hw.subject,
      text: hw.text,
      deadline: hw.deadline,
      completion: hw.completion,
      priority: hw.priority,
      index: _hwList.length - 1,
    ); // v hwlistu uz je, takze ma index: hwlist.lenght - 1
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
