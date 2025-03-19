import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:school_manager/models/subjects/subject_model.dart';

class SubjectDatabase {
  final _subjectBox = Hive.box('subjectBox');

  Map<int, Subject> getDatabase() {
    return _subjectBox.toMap().cast<int, Subject>();
  }

  Subject getSubject(int dbIndex) {
    return _subjectBox.get(dbIndex);
  }

  Future<int> addSubject(Subject subject) {
    return _subjectBox.add(subject);
  }

  Future<void> saveEditedSubject(int dbIndex, Subject newSubject) {
    return _subjectBox.put(dbIndex, newSubject);
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

  void delete(int dbKey){
    _subjectBox.delete(dbKey);
  }

  void deleteAllFromDisk() {
    _subjectBox.deleteFromDisk();
  }
}
