import 'package:hive_ce/hive.dart';
import 'package:schoolarc/database/hive/hive_init.dart';
import 'package:schoolarc/mock_data/mock_data.dart';
import 'package:schoolarc/models/exams/exam_entity_model.dart';

class ExamDatabase {
  final _examBox = Hive.box(examBox);

  /// returns map of Exams with their dbIndexes
  Map<String, ExamEntity> readDatabase() {
    if (MockData.useMock) {
      return MockData.exams;
    }

    return _examBox.toMap().cast<String, ExamEntity>();
  }

  ExamEntity read(String id) {
    return _examBox.get(id);
  }

  Future<void> put(String id, ExamEntity exam) async {
    return _examBox.put(id, exam);
  }

  void delete(String id) {
    _examBox.delete(id);
  }

  void deleteAllFromDisk() {
    _examBox.deleteFromDisk();
  }
}
