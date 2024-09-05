import 'package:hive/hive.dart';
import 'package:school_manager/data/subjects_data/subject_model.dart';

class SubjectDatabase {
  List<Subject> _subjects = [];

  SubjectDatabase() {
    _subjects.addAll(_myBox.get('SUBJECTS').cast<Subject>());
  }

  final _myBox = Hive.box('myBox');

  void createInitialData() {
    _subjects = [];
    _subjects = [
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

  // put data in database
  void updateDatabase() {
    _myBox.put("SUBJECTS", _subjects);
  }

  List<Subject> getDatabase() {
    return _subjects;
  }

  void addSubject(Subject subject) {
    _subjects.add(subject);
    updateDatabase();
  }

  void saveEditedSubject(int index, Subject newSubject) {
    _subjects[index] = newSubject;
    updateDatabase();
  }

  void deleteSubject(int index) {
    _subjects.removeAt(index);
    updateDatabase();
  }
}
