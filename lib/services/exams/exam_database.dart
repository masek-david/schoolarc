import 'package:hive/hive.dart';
import 'package:school_manager/models/exams/exam_model.dart';

class ExamDatabase {
  final _examBox = Hive.box('examBox');

  /// returns map of Exams with their dbIndexes
  Map<int, Exam> getDatabase() {
    return _examBox.toMap().cast<int, Exam>();
  }

  Exam getExam(int dbKey) {
    return _examBox.get(dbKey);
  }

  /// adds new Exam and returns dbIndex of the new Exam
  Future<int> addExam(Exam exam) async {
    return await _examBox.add(exam);
  }

  /// puts/replaces Exam at dbIndex with new one
  Future<void> editExam(int dbKey, Exam exam) {
    return _examBox.put(dbKey, exam);
  }

  void deleteAllFromDisk() {
    _examBox.deleteFromDisk();
  }
}
