import 'package:hive/hive.dart';
import 'package:school_manager/exams/data/exam_model.dart';

class ExamsDatabase {
  List<Exam> _examList = [];

  // reference box
  final _mybox = Hive.box('myBox');

  // run this first time ever opening app
  void createInitialData() {
    _examList = [];
    _examList = [
      Exam(
        subject: 'sb',
        text: 'text exam',
        date: DateTime.utc(2024, 6, 8),
        priority: 1,
        isCompleted: false,
      ),
      Exam(
        subject: 'sb',
        text: 'text of test',
        date: DateTime.utc(2024, 6, 7),
        priority: 3,
        isCompleted: false,
      )
    ];
    updateDatabase();
  }

  // load data from database
  void loadData() {
    _examList = _mybox.get("EXAMS").cast<Exam>();
  }

  // update data in database
  void updateDatabase() {
    _mybox.put("EXAMS", _examList);
  }

  List<Exam> getDatabase() {
    return _examList;
  }

  Exam getExam(int index) {
    return _examList[index];
  }

  void addExam(Exam exam) {
    _examList.add(exam);
    updateDatabase();
  }

  void editExam(int index, Exam exam) {
    _examList[index] = exam;
    updateDatabase();
  }

  void deleteExam(int index) {
    _examList.removeAt(index);
    updateDatabase();
  }
}
