import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_manager/services/exams/exam_database.dart';
import 'package:school_manager/models/exams/exam_model.dart';
import 'package:school_manager/models/exams/exam_dto_model.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';
import 'package:school_manager/utils/extensions/datetime_extension.dart';
import 'package:school_manager/utils/notifications/notification_sender.dart';
import 'package:school_manager/tasks_app.dart';

class ExamService {
  final ExamDatabase _db = ExamDatabase();

  // key is the dbIndex
  late Map<int, Exam> _examDbIndexMap = _db.getDatabase();

  // key is the priority, for each priority is a list of dbIndexes
  late Map<int, List<int>> _sequence = _db.getSequence();

  /// map with dbIndex and index in sequence, to return them to correct position
  final Map<int, int> hwsRemovedFromSequence = {};

  ExamService() {
    markAllCompletedExams();
  }

  // projde vsechny testy a ty co uz probehly oznaci jako hotove
  void markAllCompletedExams() {
    Map<int, Exam> examList = _db.getDatabase();

    examList.forEach(
      (dbIndex, exam) {
        if (exam.completion == false) {
          if (exam.date.isBeforeToday()) {
            edit(exam.copyWith(completion: true), dbIndex);
          }
        }
      },
    );

    _db.saveSequence(_sequence);
  }

  /// edits the position and priority of a Exam at the provided index
  Future<void> changeSequence(
    int oldIndex,
    int oldPriority,
    int newIndex,
    int newPriority,
  ) async {
    int movedExamDbIndex = _sequence[oldPriority]![oldIndex];
    Exam movedExam = _examDbIndexMap[movedExamDbIndex]!;
    movedExam.priority = newPriority;
    await _db.editExam(
      movedExamDbIndex,
      movedExam.copyWith(timestamp: DateTime.now()),
    );
    _sequence[oldPriority]!.removeAt(oldIndex);
    _sequence[newPriority]!.insert(newIndex, movedExamDbIndex);
    await _db.saveSequence(_sequence);
    NotificationSender.scheduleTommorrowNotification();

    return;
  }

  /// returns even deleted
  List<ExamDTO> getAll() {
    final Map<int, SubjectDTO> subjectDbIndex = subjectService.getMap();

    List<ExamDTO> list = [];
    _examDbIndexMap = _db.getDatabase();

    _examDbIndexMap.forEach(
      (dbIndex, exam) {
        list.add(
          exam.convertToDTO(
            dbIndex,
            subjectDbIndex[exam.subjectDbIndex],
          ),
        );
      },
    );

    return list;
  }

  List<ExamDTO> getForDay(DateTime date) {
    final dateUtc = date.toUtc();
    final examByDate = sortByDate();

    final dateNoTime = DateTime.utc(dateUtc.year, dateUtc.month, dateUtc.day);

    return examByDate[dateNoTime] ?? [];
  }

  /// returns map with datetime being only the date in UTC, not the time
  Map<DateTime, List<ExamDTO>> sortByDate() {
    final Map<int, SubjectDTO> subjectsDbIndex = subjectService.getMap();

    Map<DateTime, List<ExamDTO>> examDateMap = {};
    _examDbIndexMap = _db.getDatabase();

    _examDbIndexMap.forEach(
      (dbIndex, exam) {
        DateTime dateNoTime =
            DateTime.utc(exam.date.year, exam.date.month, exam.date.day);

        if (!exam.isDeleted) {
          if (examDateMap.containsKey(dateNoTime)) {
            // If it exists, add the event to the existing list
            examDateMap[dateNoTime]!.add(
              exam.convertToDTO(
                dbIndex,
                subjectsDbIndex[exam.subjectDbIndex],
              ),
            );
          } else {
            // If it does not exist, create a new list with the exam
            examDateMap[dateNoTime] = [
              exam.convertToDTO(
                dbIndex,
                subjectsDbIndex[exam.subjectDbIndex],
              ),
            ];
          }
        }
      },
    );

    examDateMap.forEach((key, value) {
      value.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    });

    return examDateMap;
  }

  Map<int, List<ExamDTO>> sortByPriority() {
    final Map<int, SubjectDTO> subjectsDbIndex = subjectService.getMap();

    _examDbIndexMap = _db.getDatabase();
    _sequence = _db.getSequence();

    Map<int, List<ExamDTO>> examPriorityMap = {
      0: <ExamDTO>[],
      1: <ExamDTO>[],
      2: <ExamDTO>[],
      3: <ExamDTO>[],
    };

    _sequence.forEach((priority, list) {
      for (int i = 0; i < list.length; i++) {
        Exam exam = _examDbIndexMap[list[i]]!;
        if (!exam.completion && !exam.isDeleted) {
          examPriorityMap[priority]!.add(
            exam.convertToDTO(
              list[i],
              subjectsDbIndex[exam.subjectDbIndex],
            ),
          );
        }
      }
    });

    return examPriorityMap;
  }

  List<ExamDTO> getCompletedExams() {
    final Map<int, SubjectDTO> subjectsDbIndex = subjectService.getMap();

    List<ExamDTO> completedExams = [];
    _examDbIndexMap = _db.getDatabase();

    _examDbIndexMap.forEach(
      (dbIndex, exam) {
        if (exam.completion && !exam.isDeleted) {
          completedExams.add(
            exam.convertToDTO(
              dbIndex,
              subjectsDbIndex[exam.subjectDbIndex],
            ),
          );
        }
      },
    );

    return completedExams;
  }

  Future<void> delete(ExamDTO exam) {
    return edit(
      exam
          .copyWith(
            isDeleted: true,
            timestamp: Timestamp.now(),
          )
          .convert(),
      exam.dbIndex,
    );
  }

  Future<void> revertDelete(int dbIndex) {
    final exam = _db.getExam(dbIndex);

    return edit(
      exam.copyWith(
        isDeleted: false,
        timestamp: DateTime.now(),
      ),
      dbIndex,
    );
  }

  /// returns id for the new exam, completion is set automatically, timestamp not
  Future<int> saveNew(Exam exam) async {
    final newExamId = await _db.addExam(exam);

    if (exam.date.isBeforeToday()) {
      exam.completion = true;
    } else {
      exam.completion = false;
    }

    _examDbIndexMap[newExamId] = exam;
    if (!exam.isDeleted && !exam.completion) {
      _sequence[exam.priority]!.add(newExamId);
      await _db.saveSequence(_sequence);
    }

    NotificationSender.scheduleTommorrowNotification();
    return newExamId;
  }

  /// completion is set automaticaly
  Future<void> edit(Exam exam, int dbIndex) async {
    final oldExam = _db.getExam(dbIndex);
    int oldPriority = oldExam.priority;
    bool oldCompletion = oldExam.completion;
    bool oldIsDeleted = oldExam.isDeleted;

    _sequence = _db.getSequence();

    if (exam.date.isBeforeToday()) {
      exam.completion = true;
    } else {
      exam.completion = false;
    }

    await _db.editExam(dbIndex, exam);
    _examDbIndexMap.update(
      dbIndex,
      (value) => exam,
    );

    if (exam.isDeleted != oldIsDeleted || exam.completion != oldCompletion) {
      if (exam.isDeleted || exam.completion) {
        // we need to remove it from sequence and save where it was
        hwsRemovedFromSequence[dbIndex] =
            _sequence[exam.priority]!.indexOf(dbIndex);
        _sequence[oldPriority]!.remove(dbIndex);
      } else {
        // if it isnt deleted and isnt completed, we need to add it back to sequence
        int indexToInsertTo =
            hwsRemovedFromSequence[dbIndex] ?? _sequence[exam.priority]!.length;

        var list = _sequence[exam.priority]!;
        list.insert(
            indexToInsertTo > list.length || indexToInsertTo < 0
                ? list.length
                : indexToInsertTo,
            dbIndex);
        hwsRemovedFromSequence.remove(dbIndex);
      }
      _db.saveSequence(_sequence);
    }
    // if priority changes we need to edit it in sequence
    if (exam.priority != oldPriority && !exam.isDeleted && !exam.completion) {
      _sequence[oldPriority]!.remove(dbIndex);
      _sequence[exam.priority]!.add(dbIndex);
      _db.saveSequence(_sequence);
    }

    NotificationSender.scheduleTommorrowNotification();
    return;
  }

  ExamDTO getExam(int dbIndex) {
    final Map<int, SubjectDTO> subjectsDbIndex = subjectService.getMap();
    Exam exam = _db.getExam(dbIndex);

    return exam.convertToDTO(
      dbIndex,
      subjectsDbIndex[exam.subjectDbIndex],
    );
  }

  int getNumberOfIncomplete() {
    _examDbIndexMap = _db.getDatabase();
    int numberOfUncomplete = 0;

    _examDbIndexMap.forEach(
      (dbIndex, exam) {
        if (!exam.completion && !exam.isDeleted) {
          numberOfUncomplete++;
        }
      },
    );

    return numberOfUncomplete;
  }
}
