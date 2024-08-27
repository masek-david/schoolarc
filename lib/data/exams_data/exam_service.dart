import 'package:school_manager/data/exams_data/exam_database.dart';
import 'package:school_manager/data/exams_data/exam_model.dart';
import 'package:school_manager/data/exams_data/exam_dto_model.dart';

class ServiceExam {
  final ExamDatabase _db = ExamDatabase();
  Map<int, Exam> _examDbIndexMap = {};
  Map<int, List<int>> _sequence = {};
  Exam? lastlyDeletedExam;
  int? lastlyDeletedExamDbIndex;
  int? lastlyDeletedExamIndex;

  void initiate() {
    _db.initiateDatabase();
    _examDbIndexMap = _db.getDatabase();
    _sequence = _db.getSequence();
  }

  // projde vsechny testy a ty co uz probehly oznaci jako hotove
  void markAllCompletedExams() {
    Map<int, Exam> examList = _db.getDatabase();
    examList.forEach(
      (dbIndex, exam) {
        if (exam.completion == false) {
          if (isBeforeToday(exam.date)) {
            _db.changeCompletion(dbIndex);
          }
        }
      },
    );
  }

  // vrati true pokud je date vcera a drive, false pokud dnes
  bool isBeforeToday(DateTime date) {
    DateTime now = DateTime.now();
    DateTime dateOnlyDate = DateTime(date.year, date.month, date.day);
    DateTime nowOnlyDate = DateTime(now.year, now.month, now.day);

    return dateOnlyDate.isBefore(DateTime.now()) &&
        !dateOnlyDate.isAtSameMomentAs(nowOnlyDate);
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

  /// returns map with datetime being only the date, not the time
  Map<DateTime, List<ExamDTO>> sortByDate() {
    Map<DateTime, List<ExamDTO>> examDateMap = {};

    _examDbIndexMap.forEach(
      (dbIndex, value) {
        DateTime dateNoTime =
            DateTime(value.date.year, value.date.month, value.date.day);
        if (examDateMap.containsKey(dateNoTime)) {
          // If it exists, add the event to the existing list
          examDateMap[dateNoTime]!.add(value.convertToDTO(dbIndex));
        } else {
          // If it does not exist, create a new list with the exam
          examDateMap[dateNoTime] = [value.convertToDTO(dbIndex)];
        }
      },
    );

    examDateMap.forEach((key, value) {
      value.sort((a, b) => b.priority.compareTo(a.priority));
    });

    return examDateMap;
  }

  Map<int, List<ExamDTO>> sortByPriority() {
    Map<int, List<ExamDTO>> examPriorityMap = {
      0: <ExamDTO>[],
      1: <ExamDTO>[],
      2: <ExamDTO>[],
      3: <ExamDTO>[],
    };

    _sequence.forEach((priority, list) {
      for (int i = 0; i < list.length; i++) {
        Exam exam = _examDbIndexMap[list[i]]!;
        if (!exam.completion) {
          examPriorityMap[priority]!.add(exam.convertToDTO(list[i]));
        }
      }
    });

    return examPriorityMap;
  }

  List<ExamDTO> getCompletedExams() {
    List<ExamDTO> completedExams = [];

    _examDbIndexMap.forEach(
      (dbIndex, exam) {
        if (exam.completion) {
          completedExams.add(exam.convertToDTO(dbIndex));
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
  }

  void revertLastlyDeletedExam() {
    if (lastlyDeletedExam != null &&
        lastlyDeletedExamIndex != null &&
        lastlyDeletedExamDbIndex != null) {
      _db.editExam(lastlyDeletedExamDbIndex!, lastlyDeletedExam!);
      _sequence[lastlyDeletedExam!.priority]!
          .insert(lastlyDeletedExamIndex!, lastlyDeletedExamDbIndex!);
      _examDbIndexMap[lastlyDeletedExamDbIndex!] = lastlyDeletedExam!;
      _db.saveSequence(_sequence);

      lastlyDeletedExam = null;
      lastlyDeletedExamIndex = null;
      lastlyDeletedExamDbIndex = null;
    }
  }

  /// saves new homework and puts it at the end of the sequence of correct priority
  Future<void> saveNewExam({
    required DateTime date,
    required int priority,
    required String subject,
    required String text,
  }) async {
    Exam newExam = Exam(
      subject: subject,
      text: text,
      date: date,
      priority: priority,
      completion: isBeforeToday(date),
    );
    int dbIndex = await _db.addExam(newExam);
    _examDbIndexMap[dbIndex] = newExam;
    _sequence[priority]!.add(dbIndex);
    _db.saveSequence(_sequence);
    return;
  }

  /// saves edited homework and changes its position in sequence if necessary
  void saveEditedExam({
    required DateTime date,
    required int priority,
    required String subject,
    required String text,
    required int dbIndex,
  }) {
    int oldPriority = _examDbIndexMap[dbIndex]!.priority;
    Exam editedExam = Exam(
        subject: subject,
        text: text,
        date: date,
        priority: priority,
        completion: isBeforeToday(date));
    _db.editExam(dbIndex, editedExam);
    _examDbIndexMap.update(
      dbIndex,
      (value) => editedExam,
    );

    if (oldPriority != editedExam.priority) {
      _sequence[oldPriority]!.remove(dbIndex);
      _sequence[editedExam.priority]!.add(dbIndex);
      _db.saveSequence(_sequence);
    }
  }

  ExamDTO getExam(int dbIndex) {
   return _db.getExam(dbIndex).convertToDTO(dbIndex);
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
