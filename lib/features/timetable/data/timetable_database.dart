import 'package:hive_ce/hive.dart';
import 'package:schoolarc/database/hive/hive_init.dart';
import 'package:schoolarc/features/timetable/domain/timetable_entity_model.dart';
import 'package:schoolarc/mock_data/mock_data.dart';

class TimetableDatabase {
  final _box = Hive.box(timetableBox);
  final _key = 'table';

  TimetableEntity read() {
    if (MockData.useMock) {
      return MockData.timetable.toEntity();
    }

    return _box.get(_key) ??
        TimetableEntity(periods: [], table: List.generate(7, (i) => []));
  }

  Future<void> put(TimetableEntity timetable) {
    return _box.put(_key, timetable);
  }
}
