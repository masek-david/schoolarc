import 'package:riverpod/riverpod.dart';
import 'package:school_manager/models/homeworks/hw_dto_model.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';
import 'package:school_manager/provider/subject_notifier.dart';
import 'package:school_manager/services/homeworks/hw_database.dart';

final hwProvider =
    StateNotifierProvider<HwNotifier, Map<int, HomeworkDTO>>((ref) {
  final subjects = ref.watch(subjectsProvider);

  return HwNotifier(HomeworksDatabase(), subjects);
});

class HwNotifier extends StateNotifier<Map<int, HomeworkDTO>> {
  final HomeworksDatabase _db;
  Map<int, SubjectDTO> subjects;

  HwNotifier(this._db, this.subjects)
      : super(_db.getDatabase().map(
          (key, value) {
            return MapEntry(
                key, value.convertToDTO(key, subjects[value.subjectDbIndex]));
          },
        ));
}
