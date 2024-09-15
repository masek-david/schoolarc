import 'package:hive/hive.dart';
import 'package:school_manager/data/subjects_data/subject_model.dart';

class SubjectDatabase {
  final _subjectBox = Hive.box('subjectBox');
  final _sequenceBox = Hive.box('subjectOtherData');

  void createInitialData() {
    _subjectBox.putAll({
      0: Subject(
        name: 'Math',
        shortcut: 'Ma',
      ),
      1: Subject(
        name: 'English',
        shortcut: 'En',
      ),
    });

    _sequenceBox.put('SEQUENCE', [0, 1]);
  }

  List<int> getSequence() {
    return _sequenceBox.get('SEQUENCE').cast<int>();
  }

  void saveSequence(List<int> newSequence) {
    _sequenceBox.put('SEQUENCE', newSequence);
  }

  Map<int, Subject> getDatabase() {
    return _subjectBox.toMap().cast<int, Subject>();
  }

  Future<int> addSubject(Subject subject) {
    return _subjectBox.add(subject);
  }

  void saveEditedSubject(int dbIndex, Subject newSubject) {
    _subjectBox.put(dbIndex, newSubject);
  }

  void deleteSubject(int dbIndex) {
    _subjectBox.delete(dbIndex);
  }

  Subject getSubject(int dbIndex) {
    return _subjectBox.get(dbIndex);
  }
}
