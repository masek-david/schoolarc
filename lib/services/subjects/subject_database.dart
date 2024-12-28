import 'package:cloud_firestore/cloud_firestore.dart';
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

  Subject getSubject(int dbIndex) {
    return _subjectBox.get(dbIndex);
  }

  Future<int> addSubject(Subject subject) {
    return _subjectBox.add(subject);
  }

  void saveEditedSubject(int dbIndex, Subject newSubject) {
    _subjectBox.put(dbIndex, newSubject);
  }

  void addTimestamp(Timestamp timestamp, int dbIndex) {
    final hw = getSubject(dbIndex);

    _subjectBox.put(
      dbIndex,
      hw.copyWith(
        timestamp: timestamp.toDate(),
      ),
    );
  }

  void deleteAllFromDisk() {
    _subjectBox.deleteFromDisk();
    _sequenceBox.deleteFromDisk();
  }
}
