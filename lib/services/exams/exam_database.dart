import 'package:hive/hive.dart';
import 'package:school_manager/models/exams/exam_model.dart';

class ExamDatabase {
  final _examBox = Hive.box('examBox');
  final _examSequenceBox = Hive.box('examOtherData');

  /// returns list of Exams dbIndexes for each priority
  Map<int, List<int>> getSequence() {
    var map = _examSequenceBox.get('sequence') ??
        {
          0: <int>[],
          1: <int>[],
          2: <int>[],
          3: <int>[],
        };
    return map.cast<int, List<int>>();
  }

  Future<void> saveSequence(Map<int, List<int>> sequence) {
    return _examSequenceBox.put('sequence', sequence);
  }

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
    _examSequenceBox.deleteFromDisk();
  }
}
