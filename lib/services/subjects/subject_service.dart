import 'package:school_manager/services/subjects/subject_database.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';
import 'package:school_manager/models/subjects/subject_model.dart';

class SubjectService {
  final _db = SubjectDatabase();
  late Map<int, Subject> _subjectDbIndexMap = _db.getDatabase();
  late List<int> _sequence = _db.getSequence();

  SubjectDTO? lastDeletedSubject;
  int? lastDeletedSequenceIndex;

  void changeSequence(int oldIndex, int newIndex) {
    int dbIndex = _sequence.removeAt(oldIndex);
    _sequence.insert(newIndex, dbIndex);
    _db.saveSequence(_sequence);
  }

  List<SubjectDTO> getSortedList() {
    _subjectDbIndexMap = _db.getDatabase();
    _sequence = _db.getSequence();
    List<SubjectDTO> list = [];

    for (int element in _sequence) {
      Subject subject = _subjectDbIndexMap[element]!;
      list.add(subject.convertToDTO(element));
    }

    return list;
  }

  Map<int, SubjectDTO> getMap() {
    _subjectDbIndexMap = _db.getDatabase();
    return _subjectDbIndexMap.map(
      (key, value) => MapEntry(key, value.convertToDTO(key)),
    );
  }

  Future<SubjectDTO> addNewSubject(Subject subject) async {
    int dbIndex = await _db.addSubject(subject);

    _sequence.add(dbIndex);
    _db.saveSequence(_sequence);
    _subjectDbIndexMap = _db.getDatabase();

    return subject.convertToDTO(dbIndex);
  }

  void editSubject(SubjectDTO editedSubject) {
    _db.saveEditedSubject(editedSubject.dbIndex, editedSubject.convert());
  }

  void deleteSubject(int dbIndex) {
    lastDeletedSubject = _db.getSubject(dbIndex).convertToDTO(dbIndex);
    lastDeletedSequenceIndex = _sequence.indexOf(dbIndex);

    _db.deleteSubject(dbIndex);
    _sequence.remove(dbIndex);
    _db.saveSequence(_sequence);
  }

  void deleteAllSubjects() {
    _subjectDbIndexMap.forEach(
      (key, value) {
        deleteSubject(key);
      },
    );
  }

  void revertLastlyDeletedSubject() {
    if (lastDeletedSubject != null && lastDeletedSequenceIndex != null) {
      _db.saveEditedSubject(
          lastDeletedSubject!.dbIndex, lastDeletedSubject!.convert());
      _sequence.insert(lastDeletedSequenceIndex!, lastDeletedSubject!.dbIndex);

      lastDeletedSequenceIndex = null;
      lastDeletedSubject = null;
    }
  }

  SubjectDTO getSubject(int dbIndex) {
    return _db.getSubject(dbIndex).convertToDTO(dbIndex);
  }
}
