import 'package:hive/hive.dart';
import 'package:school_manager/data/exams_data/exam_model.dart';

class ExamDatabase {
  final _examBox = Hive.box('examBox');
  final _examSequenceBox = Hive.box('examOtherData');

  /// initial data will be inserted
  void createInitialData() {
    _examBox.putAll({
      3: Exam(
          subject: 'Math',
          text: 'This is the text of the exam',
          date: DateTime.now(),
          completion: false,
          priority: 3),
      2: Exam(
          subject: 'En',
          text: '<- here you can see the subject',
          date: DateTime.now(),
          completion: false,
          priority: 2),
      1: Exam(
          subject: 'Ma',
          text: 'Algrebra',
          date: DateTime.now(),
          completion: false,
          priority: 1),
      0: Exam(
          subject: 'Bio',
          text: 'Mammals',
          date: DateTime.now(),
          completion: false,
          priority: 0),
    });

    Map<int, List<int>> sequence = {
      0: [0],
      1: [1],
      2: [2],
      3: [3],
    };
    _examSequenceBox.put('sequence', sequence);
  }

  /// returns list of Exams dbIndexes for each priority
  Map<int, List<int>> getSequence() {
    return Map.from(_examSequenceBox.get('sequence'));
  }

  void saveSequence(Map<int, List<int>> sequence) {
    _examSequenceBox.put('sequence', sequence);
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
  void editExam(int dbKey, Exam exam) {
    _examBox.put(dbKey, exam);
  }

  void deleteExam(int dbKey) {
    _examBox.delete(dbKey);
  }

  void setCompletion(int dbKey, bool value) {
    Exam exam = _examBox.get(dbKey);
    exam.completion = !exam.completion;

    _examBox.put(
      dbKey,
      Exam(
        subject: exam.subject,
        text: exam.text,
        date: exam.date,
        priority: exam.priority,
        completion: value,
      ),
    );
  }
}
