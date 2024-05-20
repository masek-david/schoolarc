import 'package:hive/hive.dart';

class HomeworksDatabase {
  List hwList = [];

  // reference box
  final _mybox = Hive.box('myBox');

  // run this first time ever opening app
  void createInitialData() {
    hwList = [
      // [0]subject, [1]text, [2]deadline, [3]completion, [4]priority
      ["predmet", "Tady je zobrazi text ukolu", DateTime(2024), false, 1],
      ["Ma", "uc 23/34", DateTime(2023), false, 2]
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
}
