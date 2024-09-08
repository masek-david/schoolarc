import 'package:hive/hive.dart';
import 'package:school_manager/data/subjects_data/subject_model.dart';

class SubjectDatabase {
  final List<Subject> _subjects = [];

  SubjectDatabase() {
    _subjects.addAll(_myBox.get('SUBJECTS').cast<Subject>());
  }

  final _myBox = Hive.box('myBox');

  static void createInitialData() {
    final box = Hive.box('myBox');

    box.put('SUBJECTS', [
      Subject(
        name: 'Math',
        shortcut: 'Ma',
      ),
      Subject(
        name: 'English',
        shortcut: 'En',
      )
    ]);
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
