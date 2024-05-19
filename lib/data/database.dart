import 'package:hive/hive.dart';

class HomeworksDatabase {
  List hwList = [];
  
  // reference box
  final _mybox = Hive.box('myBox');

  // run this first time ever opening app
  void createInitialData() {
    hwList = [["Cj", "ps 12/5", DateTime(2024), false],
     ["Ma", "uc 23/34", DateTime(2023), true],
     ["Ma", "uc 23/34", DateTime(2022), false],];
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