import 'package:hive/hive.dart';
import 'package:school_manager/exams/data/exam_database.dart';
import 'package:school_manager/exams/data/exam_model.dart';
import 'package:school_manager/exams/data/exam_dto_model.dart';

class ServiceExam {
  final _myBox = Hive.box('myBox');
  ExamsDatabase db = ExamsDatabase();
  List<Exam> examList = [];
  Map<int, List<ExamDTO>> examsByPriority = {
    0: <ExamDTO>[],
    1: <ExamDTO>[],
    2: <ExamDTO>[],
    3: <ExamDTO>[],
  };
  Map<DateTime, List<ExamDTO>> examsByDate = {};

  void initiate() {
    // if first time ever opening app, create initial data
    // db.createInitialData();
    if (_myBox.get("EXAMS") == null) {
      db.createInitialData();
    } else {
      // there already exist data
      db.loadData();
    }
  }

  void cleanExamsByPriority() {
    for (int i = 0; i <= 3; i++) {
      examsByPriority[i]!.clear();
    }
  }

  void cleanExamsByDate() {
    examsByDate.forEach((key, value){examsByDate[key]!.clear();});
  }

  Map<DateTime, List<ExamDTO>> sortByDate() {
    examList = db.getDatabase();
    List<ExamDTO> indexedList = [];
    for (int index = 0; index < examList.length; index++) {
      Exam exam = examList[index];
      indexedList.add(ExamDTO(
          subject: exam.subject,
          text: exam.text,
          date: exam.date,
          priority: exam.priority,
          index: index));
    }
    cleanExamsByDate();
    for (ExamDTO exam in indexedList) {
      // potrebujeme pridavat pouze pro datum, ne pro cas
      DateTime examDateNoTime =
          DateTime(exam.date.year, exam.date.month, exam.date.day);
      if (examsByDate.containsKey(examDateNoTime)) {
        // If it exists, add the event to the existing list
        examsByDate[examDateNoTime]!.add(exam);
      } else {
        // If it does not exist, create a new list with the exam
        examsByDate[examDateNoTime] = [exam];
      }
    }

    examsByDate.forEach((key, value){
      value.sort((a, b) => b.priority.compareTo(a.priority));
    });

    return examsByDate;
  }

  Map<int, List<ExamDTO>> sortByPriority() {
    examList = db.getDatabase();
    List<ExamDTO> indexedList = [];
    for (int index = 0; index < examList.length; index++) {
      Exam hw = examList[index];
      indexedList.add(ExamDTO(
          subject: hw.subject,
          text: hw.text,
          date: hw.date,
          priority: hw.priority,
          index: index));
    }
    cleanExamsByPriority();
    for (ExamDTO exam in indexedList) {
      var list = examsByPriority[
          // var list je odkaz na list Exam v mape sortedHw => priradi se do mapy se spravnou prioritou
          exam.priority];
      if (list != null) {
        list.add(exam);
      }
    }
    for (int i = 0; i <= 3; i++) {
      examsByPriority[i]!.sort((a, b) => a.date.compareTo(b.date));
    }
    return examsByPriority;
  }

  void deleteExam(int index) {
    db.deleteExam(index);
    sortByPriority();
  }

  void saveNewExam({
    required DateTime date,
    required int priority,
    required String subject,
    required String text,
  }) {
    Exam newExam =
        Exam(subject: subject, text: text, date: date, priority: priority);
    db.addExam(newExam);
    ExamDTO newExamDto = convertToDTO(newExam, examList.length - 1);
    DateTime examDateNoTime = DateTime(
        newExamDto.date.year, newExamDto.date.month, newExamDto.date.day);
    examsByPriority[newExamDto.priority]!.add(newExamDto);
    if (examsByDate.containsKey(examDateNoTime)) {
      // If it exists, add the event to the existing list
      examsByDate[examDateNoTime]!.add(newExamDto);
    } else {
      // If it does not exist, create a new list with the newExamDto
      examsByDate[examDateNoTime] = [newExamDto];
    }
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
    sortByPriority();                   // musi tu byt aby se aktualizoval view
    sortByDate();
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
