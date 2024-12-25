import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_manager/services/subjects/subject_database.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';
import 'package:school_manager/models/subjects/subject_model.dart';

class SubjectService {
  final _db = SubjectDatabase();
  late Map<int, Subject> _subjectDbIndexMap = _db.getDatabase();
  late List<int> _sequence = _db.getSequence();

  void changeSequence(int oldIndex, int newIndex) {
    int dbIndex = _sequence.removeAt(oldIndex);
    _sequence.insert(newIndex, dbIndex);
    _db.saveSequence(_sequence);
  }

  List<SubjectDTO> getSortedList() {
    _subjectDbIndexMap = _db.getDatabase();
    _sequence = _db.getSequence();
    List<SubjectDTO> list = [];

    for (int key in _sequence) {
      SubjectDTO subject = _subjectDbIndexMap[key]!.convertToDTO(key);

      if (!subject.isDeleted) {
        list.add(subject);
      }
    }

    return list;
  }

  /// returns even deleted ones, not sorted
  List<SubjectDTO> getAllSubjects() {
    _subjectDbIndexMap = _db.getDatabase();
    List<SubjectDTO> list = [];

    _subjectDbIndexMap.forEach(
      (key, value) {
        list.add(value.convertToDTO(key));
      },
    );

    return list;
  }

  Map<int, SubjectDTO> getMap() {
    _subjectDbIndexMap = _db.getDatabase();

    Map<int, SubjectDTO> map = {};

    _subjectDbIndexMap.forEach(
      (key, value) {
        final subject = value.convertToDTO(key);

        if (!subject.isDeleted) {
          map[key] = subject;
        }
      },
    );

    return map;
  }

  List<SubjectDTO> getList() {
    _subjectDbIndexMap = _db.getDatabase();

    List<SubjectDTO> list = [];
    _subjectDbIndexMap.forEach(
      (key, value) {
        final subject = value.convertToDTO(key);

        if (!subject.isDeleted) {
          list.add(subject);
        }
      },
    );

    return list;
  }

  Future<SubjectDTO> addNewSubject(Subject subject, {Timestamp? timestamp}) async {
    int dbIndex = await _db.addSubject(subject.copyWith(timestamp: timestamp?.toDate()));

    _sequence.add(dbIndex);
    _db.saveSequence(_sequence);
    _subjectDbIndexMap = _db.getDatabase();

    return subject.convertToDTO(dbIndex).copyWith(timestamp: timestamp);
  }

  void editSubject(SubjectDTO editedSubject, {Timestamp? timestamp}) {
    _db.saveEditedSubject(
      editedSubject.dbIndex,
      editedSubject.convert().copyWith(
            timestamp: timestamp?.toDate(),
          ),
    );
  }

  void deleteSubject(int dbIndex) {
    _db.deleteSubject(dbIndex);
  }

  void deleteAllSubjects() {
    _subjectDbIndexMap.forEach(
      (key, value) {
        deleteSubject(key);
      },
    );
  }

  void revertDelete(int dbIndex) {
    _db.deleteSubject(dbIndex, isDeleted: false);
  }

  void addTimestamp(Timestamp timestamp, int dbIndex){
    _db.addTimestamp(timestamp, dbIndex);
  }

  SubjectDTO getSubject(int dbIndex) {
    return _db.getSubject(dbIndex).convertToDTO(dbIndex);
  }
}
