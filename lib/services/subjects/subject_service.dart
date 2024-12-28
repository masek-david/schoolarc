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

  Future<SubjectDTO> addNewSubject(Subject subject,
      {Timestamp? timestamp}) async {
    final timestampToSave =
        timestamp != null ? timestamp.toDate() : DateTime.now();

    int dbIndex = await _db.addSubject(
      subject.copyWith(timestamp: timestampToSave),
    );

    if (!subject.isDeleted) {
      _sequence.add(dbIndex);
      _db.saveSequence(_sequence);
    }
    _subjectDbIndexMap = _db.getDatabase();

    return subject.convertToDTO(dbIndex).copyWith(
          timestamp: Timestamp.fromDate(timestampToSave),
        );
  }

  /// assign timestamp manually
  void editSubject(SubjectDTO editedSubject) {
    bool oldIsDeleted = _db.getSubject(editedSubject.dbIndex).isDeleted;

    _db.saveEditedSubject(editedSubject.dbIndex, editedSubject.convert());

    if (oldIsDeleted != editedSubject.isDeleted) {
      if (editedSubject.isDeleted) {
        _sequence.remove(editedSubject.dbIndex);
      } else {
        _sequence.add(editedSubject.dbIndex);
      }

      _db.saveSequence(_sequence);
    }
  }

  void deleteSubject(int dbIndex,
      {DateTime? timestamp, bool nowIsDeleted = true}) {
    final subject = _db.getSubject(dbIndex);

    _db.saveEditedSubject(
      dbIndex,
      subject.copyWith(
        isDeleted: nowIsDeleted,
        timestamp: timestamp ?? DateTime.now(),
      ),
    );
  }

  void revertDelete(int dbIndex, {DateTime? timestamp}) {
    deleteSubject(dbIndex, timestamp: timestamp, nowIsDeleted: false);
  }

  void deleteAllSubjects() {
    _subjectDbIndexMap.forEach(
      (key, value) {
        deleteSubject(key);
      },
    );
  }

  void addTimestamp(Timestamp timestamp, int dbIndex) {
    _db.addTimestamp(timestamp, dbIndex);
  }

  SubjectDTO getSubject(int dbIndex) {
    return _db.getSubject(dbIndex).convertToDTO(dbIndex);
  }
}
