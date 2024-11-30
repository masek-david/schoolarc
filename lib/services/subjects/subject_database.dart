import 'package:hive/hive.dart';
import 'package:school_manager/models/subjects/subject_model.dart';

class SubjectDatabase {
  final _subjectBox = Hive.box('subjectBox');
  final _sequenceBox = Hive.box('subjectOtherData');

  List<int> getSequence() {
    final list = _sequenceBox.get('SEQUENCE') ?? <int>[];

    return list.cast<int>();
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
