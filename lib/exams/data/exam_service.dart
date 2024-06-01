import 'package:hive/hive.dart';
import 'package:school_manager/exams/data/exam_database.dart';
import 'package:school_manager/exams/data/exam_model.dart';
import 'package:school_manager/exams/data/exam_dto_model.dart';

class ServiceExam {
  final _myBox = Hive.box('myBox');
  ExamsDatabase db = ExamsDatabase();
  List<Exam> hwList = [];
  Map<int, List<ExamDTO>> sortedExam = {
    0: <ExamDTO>[],
    1: <ExamDTO>[],
    2: <ExamDTO>[],
    3: <ExamDTO>[],
  };

  void initiate() {
    // if first time ever opening app, create initial data
    if (_myBox.get("EXAMS") == null) {
      db.createInitialData();
    } else {
      // there already exist data
      db.loadData();
    }
  }

  void cleanSortedExamList() {
    for (int i = 0; i <= 3; i++) {
      sortedExam[i]!.clear();
    }
  }

  Map<int, List<ExamDTO>> sortExamList() {
    hwList = db.getDatabase();
    List<ExamDTO> indexedList = [];
    for (int index = 0; index < hwList.length; index++) {
      Exam hw = hwList[index];
      indexedList.add(ExamDTO(
          subject: hw.subject,
          text: hw.text,
          date: hw.date,
          priority: hw.priority,
          index: index));
    }
    cleanSortedExamList();
    for (ExamDTO exam in indexedList) {
      var list = sortedExam[
          // var list je odkaz na list Exam v mape sortedHw => priradi se do mapy se spravnou prioritou
          exam.priority];
      if (list != null) {
        list.add(exam);
      }
    }
    for (int i = 0; i <= 3; i++) {
      sortedExam[i]!.sort((a,b) => a.date.compareTo(b.date));
    }
    return sortedExam;
  }

  void deleteExam(int index) {
    db.deleteExam(index);
    sortExamList();
  }

  void saveNewExam({
    required DateTime date,
    required int priority,
    required String subject,
    required String text,
  }) {
    Exam editedHw =
        Exam(subject: subject, text: text, date: date, priority: priority);
    db.addExam(editedHw);
    ExamDTO editedHwDto = convertToDTO(editedHw, hwList.length - 1);
    sortedExam[editedHwDto.priority]!.add(editedHwDto);
  }

  void saveEditedExam({
    required DateTime date,
    required int priority,
    required String subject,
    required String text,
    required int index,
  }) {
    Exam editedHw =
        Exam(subject: subject, text: text, date: date, priority: priority);
    db.editExam(index, editedHw);
    sortExamList();
    db.updateDatabase();
  }

  ExamDTO convertToDTO(Exam exam, int index) {
    return ExamDTO(
        subject: exam.subject,
        text: exam.text,
        date: exam.date,
        priority: exam.priority,
        index: index);
  }

  ExamDTO getExam(int index) {
    Exam hw = db.getExam(index);
    return convertToDTO(hw, index);
  }
}
