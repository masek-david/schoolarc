import 'package:hive/hive.dart';
import 'package:school_manager/data/hw_model.dart';

class HomeworksDatabase {
  List hwList = [];

  // reference box
  final _mybox = Hive.box('myBox');

  // run this first time ever opening app
  void createInitialData() {
    hwList = [
      // [0]subject, [1]text, [2]deadline, [3]completion, [4]priority
      Homework(subject: 'ma', text: 'tady se zobrazi text', deadline: DateTime(2024), completion: false, priority: 1),
      Homework(subject: 'cj', text: 'uc 23/4', deadline: DateTime(2023), completion: false, priority: 2),
    ];
  }

  // load data from database
  void loadData() {
    hwList = _mybox.get("HOMEWORKS");
  }

  // update data in database
  void updateDatabase() {
    _mybox.put("HOMEWORKS", hwList);
  }

  List getDatabase() {
    return hwList;
  }

  void addHw(Homework hw) {
    hwList.add(hw);
    updateDatabase();
  }

  void deleteHw(int index) {
    hwList.removeAt(index);
    updateDatabase();
  }

  void changeCompletion(int index) {
    (hwList[index] as Homework).completion = !(hwList[index] as Homework).completion;
  }
}
