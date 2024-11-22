import 'package:flutter/material.dart';
import 'package:school_manager/data/exams_data/exam_database.dart';
import 'package:school_manager/data/exams_data/exam_model.dart';
import 'package:school_manager/data/exams_data/exam_dto_model.dart';
import 'package:school_manager/data/priority_model.dart';
import 'package:school_manager/data/subjects_data/subject_dto_model.dart';
import 'package:school_manager/extensions/datetime_extension.dart';
import 'package:school_manager/notifications/notification_sender.dart';
import 'package:school_manager/tasks_app.dart';

class ExamService {
  final ExamDatabase _db = ExamDatabase();
  late final Map<int, SubjectDTO> _subjectsDbIndex = subjectService.getMap();
  // key is the dbIndex
  late Map<int, Exam> _examDbIndexMap = _db.getDatabase();
  // key is the priority, for each priority is a list of dbIndexes
  late Map<int, List<int>> _sequence = _db.getSequence();
  Exam? lastlyDeletedExam;
  int? lastlyDeletedExamDbIndex;
  int? lastlyDeletedExamIndex;

  ExamService() {
    markAllCompletedExams();
  }

  List<TaskPriority> getPriorities(BuildContext? context) {
    List<TaskPriority> priorities = [];

    for (int i = 0; i < 4; i++) {
      priorities.add(TaskPriority(i, context));
    }

    return priorities;
  }

  // projde vsechny testy a ty co uz probehly oznaci jako hotove
  void markAllCompletedExams() {
    Map<int, Exam> examList = _db.getDatabase();

    examList.forEach(
      (dbIndex, exam) {
        if (exam.completion == false) {
          if (exam.date.isBeforeToday()) {
            _db.setCompletion(dbIndex, true);
            _sequence[exam.priority]!.remove(dbIndex);
          }
        }
      },
    );

    _db.saveSequence(_sequence);
  }

  /// edits the position and priority of a Exam at the provided index
  void changeSequence(
      int oldIndex, int oldPriority, int newIndex, int newPriority) {
    int movedExamDbIndex = _sequence[oldPriority]![oldIndex];
    Exam movedExam = _examDbIndexMap[movedExamDbIndex]!;
    movedExam.priority = newPriority;
    _db.editExam(movedExamDbIndex, movedExam);
    _sequence[oldPriority]!.removeAt(oldIndex);
    _sequence[newPriority]!.insert(newIndex, movedExamDbIndex);
    _db.saveSequence(_sequence);
  }

  List<ExamDTO> getForDay(DateTime date, BuildContext? context) {
    final dateUtc = date.toUtc();
    final examByDate = sortByDate(context);

    final dateNoTime = DateTime.utc(dateUtc.year, dateUtc.month, dateUtc.day);

    return examByDate[dateNoTime] ?? [];
  }

  /// returns map with datetime being only the date in UTC, not the time
  Map<DateTime, List<ExamDTO>> sortByDate(BuildContext? context) {
    Map<DateTime, List<ExamDTO>> examDateMap = {};
    _examDbIndexMap = _db.getDatabase();
    final priorities = getPriorities(context);

    _examDbIndexMap.forEach(
      (dbIndex, exam) {
        DateTime dateNoTime =
            DateTime.utc(exam.date.year, exam.date.month, exam.date.day);
        if (examDateMap.containsKey(dateNoTime)) {
          // If it exists, add the event to the existing list
          examDateMap[dateNoTime]!.add(
            exam.convertToDTO(
              dbIndex,
              _subjectsDbIndex[exam.subjectDbIndex],
              priorities[exam.priority],
            ),
          );
        } else {
          // If it does not exist, create a new list with the exam
          examDateMap[dateNoTime] = [
            exam.convertToDTO(
              dbIndex,
              _subjectsDbIndex[exam.subjectDbIndex],
              priorities[exam.priority],
            ),
          ];
        }
      },
    );

    examDateMap.forEach((key, value) {
      value.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    });

    return examDateMap;
  }

  Map<int, List<ExamDTO>> sortByPriority(BuildContext? context) {
    _examDbIndexMap = _db.getDatabase();
    _sequence = _db.getSequence();

    Map<int, List<ExamDTO>> examPriorityMap = {
      0: <ExamDTO>[],
      1: <ExamDTO>[],
      2: <ExamDTO>[],
      3: <ExamDTO>[],
    };
    final priorities = getPriorities(context);

    _sequence.forEach((priority, list) {
      for (int i = 0; i < list.length; i++) {
        Exam exam = _examDbIndexMap[list[i]]!;
        if (!exam.completion) {
          examPriorityMap[priority]!.add(
            exam.convertToDTO(
              list[i],
              _subjectsDbIndex[exam.subjectDbIndex],
              priorities[exam.priority],
            ),
          );
        }
      }
    });

    return examPriorityMap;
  }

  List<ExamDTO> getCompletedExams(BuildContext? context) {
    _examDbIndexMap = _db.getDatabase();
    List<ExamDTO> completedExams = [];
    final priorities = getPriorities(context);

    _examDbIndexMap.forEach(
      (dbIndex, exam) {
        if (exam.completion) {
          completedExams.add(
            exam.convertToDTO(
              dbIndex,
              _subjectsDbIndex[exam.subjectDbIndex],
              priorities[exam.priority],
            ),
          );
        }
      },
    );

    return completedExams;
  }

  /// deletes howework and saves it for reverting
  void deleteExam(int dbIndex) {
    lastlyDeletedExam = _db.getExam(dbIndex);
    lastlyDeletedExamDbIndex = dbIndex;
    lastlyDeletedExamIndex =
        _sequence[lastlyDeletedExam!.priority]!.indexOf(dbIndex);

    _sequence[lastlyDeletedExam!.priority]!.remove(dbIndex);
    _db.saveSequence(_sequence);

    _db.deleteExam(dbIndex);
    _examDbIndexMap.remove(dbIndex);

    NotificationSender.scheduleTommorrowNotification();
  }

  void revertLastlyDeletedExam() {
    if (lastlyDeletedExam != null &&
        lastlyDeletedExamIndex != null &&
        lastlyDeletedExamDbIndex != null) {
      _db.editExam(lastlyDeletedExamDbIndex!, lastlyDeletedExam!);
      if (!lastlyDeletedExam!.completion) {
        _sequence[lastlyDeletedExam!.priority]!
            .insert(lastlyDeletedExamIndex!, lastlyDeletedExamDbIndex!);
      }
      _examDbIndexMap[lastlyDeletedExamDbIndex!] = lastlyDeletedExam!;
      _db.saveSequence(_sequence);

      lastlyDeletedExam = null;
      lastlyDeletedExamIndex = null;
      lastlyDeletedExamDbIndex = null;
    }

    NotificationSender.scheduleTommorrowNotification();
  }

  /// saves new homework and puts it at the end of the sequence of correct priority
  Future<void> saveNewExam({
    required DateTime date,
    required int priority,
    required SubjectDTO? subject,
    required String text,
  }) async {
    Exam newExam = Exam(
      subjectDbIndex: subject?.dbIndex,
      text: text,
      date: date,
      priority: priority,
      completion: date.isBeforeToday(),
    );
    int dbIndex = await _db.addExam(newExam);
    _examDbIndexMap[dbIndex] = newExam;
    if (!date.isBeforeToday()) {
      _sequence[priority]!.add(dbIndex);
      _db.saveSequence(_sequence);
    }

    NotificationSender.scheduleTommorrowNotification();

    return;
  }

  /// saves edited homework and changes its position in sequence if necessary
  void saveEditedExam({
    required DateTime date,
    required int priority,
    required SubjectDTO? subject,
    required String text,
    required int dbIndex,
  }) {
    int oldPriority = _examDbIndexMap[dbIndex]!.priority;

    bool isAlreadyCompleted = date.isBeforeToday();
    Exam editedExam = Exam(
      subjectDbIndex: subject?.dbIndex,
      text: text,
      date: date,
      priority: priority,
      completion: isAlreadyCompleted,
    );

    _db.editExam(dbIndex, editedExam);
    _examDbIndexMap.update(
      dbIndex,
      (value) => editedExam,
    );

    if (oldPriority != editedExam.priority) {
      // priority changed, must change place in sequence
      _sequence[oldPriority]!.remove(dbIndex);
      _sequence[editedExam.priority]!.add(dbIndex);
    }

    if (isAlreadyCompleted) {
      // it already happened, remove it from sequence
      _sequence[priority]!.remove(dbIndex);
    } else if (!_sequence[priority]!.contains(dbIndex)) {
      // if it wasnt in the list, it has to be added
      _sequence[priority]!.add(dbIndex);
    }

    _db.saveSequence(_sequence);
  }

  ExamDTO getExam(int dbIndex, BuildContext? context) {
    Exam exam = _db.getExam(dbIndex);
    final priorities = getPriorities(context);

    return exam.convertToDTO(
      dbIndex,
      _subjectsDbIndex[exam.subjectDbIndex],
      priorities[exam.priority],
    );
  }

  int getNumberOfIncomplete() {
    int numberOfUncomplete = 0;
    _examDbIndexMap.forEach(
      (dbIndex, value) {
        if (!value.completion) {
          numberOfUncomplete++;
        }
      },
    );

    return numberOfUncomplete;
  }
}
