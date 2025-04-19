import 'package:hive_ce/hive.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';
import 'package:school_manager/models/subjects/subject_model.dart';

class SubjectDatabase {
  final _subjectBox = Hive.box('subjectBox');

  Map<String, SubjectDTO> getDatabase() {
    return _subjectBox.toMap().cast<String, Subject>().map(
          (key, value) => MapEntry(key, value.convertToDTO(key)),
        );
  }

  SubjectDTO getSubject(String id) {
    return _subjectBox.get(id);
  }

  Future<void> addSubject(String id, Subject subject) {
    return _subjectBox.put(id, subject);
  }

  Future<void> saveEditedSubject(String id, Subject subject) {
    return _subjectBox.put(id, subject);
  }

  void delete(String id) {
    _subjectBox.delete(id);
  }

  void deleteAllFromDisk() {
    _subjectBox.deleteFromDisk();
  }
}
