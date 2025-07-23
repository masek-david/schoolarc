import 'package:hive_ce/hive.dart';
import 'package:schoolarc/database/hive/hive_init.dart';
import 'package:schoolarc/models/exams/exam_entity_model.dart';

class ExamDatabase {
  final _examBox = Hive.box(examBox);

  /// returns map of Exams with their dbIndexes
  Map<String, ExamEntity> getDatabase() {
    return _examBox.toMap().cast<String, ExamEntity>();
  }

  ExamEntity getExam(String id) {
    return _examBox.get(id);
  }

  /// adds new Exam
  Future<void> addExam(String id, ExamEntity exam) async {
    return _examBox.put(id, exam.copyWith(date: exam.date.toUtc()));
  }

  /// puts/replaces Exam at dbIndex with new one
  Future<void> editExam(String id, ExamEntity exam) {
    return _examBox.put(id, exam.copyWith(date: exam.date.toUtc()));
  }

  void delete(String id) {
    _examBox.delete(id);
  }

  void deleteAllFromDisk() {
    _examBox.deleteFromDisk();
  }
}
