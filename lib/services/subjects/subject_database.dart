import 'package:hive_ce/hive.dart';
import 'package:school_manager/models/subjects/subject_model.dart';
import 'package:school_manager/models/subjects/subject_entity_model.dart';

class SubjectDatabase {
  final _subjectBox = Hive.box('subjectBox');

  Map<String, Subject> getDatabase() {
    return _subjectBox.toMap().cast<String, SubjectEntity>().map(
          (key, value) => MapEntry(key, value.convert(key)),
        );
  }

  Subject getSubject(String id) {
    return _subjectBox.get(id);
  }

  Future<void> addSubject(String id, SubjectEntity subject) {
    return _subjectBox.put(id, subject);
  }

  Future<void> saveEditedSubject(String id, SubjectEntity subject) {
    return _subjectBox.put(id, subject);
  }

  void delete(String id) {
    _subjectBox.delete(id);
  }

  void deleteAllFromDisk() {
    _subjectBox.deleteFromDisk();
  }
}
