import 'package:hive/hive.dart';
import 'package:school_manager/subjects/subject_model.dart';

class SubjectDatabase {
  List<Subject> subjects = [];

  final _myBox = Hive.box('myBox');

  void initiate() {
    // if first time ever opening app, create initial data
    if (_myBox.get("SUBJECTS") == null) {
      createInitialData();
    } else {
      // there already exist data
      loadData();
    }
  }

  void createInitialData() {
    subjects = [];
    subjects = [
      Subject(
        name: 'Math',
        shortcut: 'Ma',
      ),
      Subject(
        name: 'English',
        shortcut: 'En',
      )
    ];
    updateDatabase();
  }

  void loadData() {
    subjects = _myBox.get("SUBJECTS").cast<Subject>();
  }

  // update data in database
  void updateDatabase() {
    _myBox.put("SUBJECTS ", subjects);
  }

  List<Subject> getDatabase() {
    return subjects;
  }

  void addSubject(String name, String shortcut) {
    subjects.add(Subject(name: name, shortcut: shortcut));
    updateDatabase();
  }

  void deleteSubject() {
    // TODO
  }
}
