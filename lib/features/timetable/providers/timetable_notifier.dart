import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/features/timetable/data/timetable_database.dart';
import 'package:schoolarc/features/timetable/domain/lesson_entity_model.dart';
import 'package:schoolarc/features/timetable/domain/period_model.dart';
import 'package:schoolarc/features/timetable/domain/timetable_entity_model.dart';
import 'package:schoolarc/provider/subject_notifier.dart';

final timetableDataProvider = NotifierProvider(TimetableNotifier.new);

final timetableProvider = Provider(
  (ref) {
    final subjects = ref.watch(subjectsNonDeletedProvider);
    final timetable = ref.watch(timetableDataProvider);

    return timetable.convert(subjects);
  },
);

class TimetableNotifier extends Notifier<TimetableEntity> {
  final _db = TimetableDatabase();

  @override
  TimetableEntity build() {
    return _db.read();
  }

  void _saveState() {
    _db.put(state);
    state = state.copyWith();
  }

  void overriderTimetable(TimetableEntity timetable) {
    state = timetable;
    _saveState();
  }

  /// Returns the index where the [period] should be inserted
  int _getIndexForPeriod(Period period) {
    int index = state.periods.length;
    for (int i = 0; i < state.periods.length; i++) {
      if (period.startTime.isBefore(state.periods[i].startTime)) {
        index = i;
        break;
      }
    }
    return index;
  }

  void createPeriod(Period period) {
    final newIndex = _getIndexForPeriod(period);
    state.periods.insert(newIndex, period);
    for (final day in state.table) {
      day.insert(newIndex, const LessonEntity.empty());
    }

    _saveState();
  }

  void editPeriod({required final int oldIndex, required final Period period}) {
    state.periods.removeAt(oldIndex);
    final newIndex = _getIndexForPeriod(period);

    for (final day in state.table) {
      day.insert(newIndex, day.removeAt(oldIndex));
    }

    state.periods.insert(newIndex, period);
    _saveState();
  }

  void deletePeriod(int index) {
    state.periods.removeAt(index);
    for (final day in state.table) {
      day.removeAt(index);
    }
    _saveState();
  }

  void putLessonAt({
    required final int weekday,
    required final int index,
    required final LessonEntity lesson,
  }) {
    state.table[weekday][index] = lesson;
    _saveState();
  }

  void deleteLessonAt({
    required final int weekday,
    required final int index,
  }) {
    state.table[weekday][index] = const LessonEntity.empty();
    _saveState();
  }
}
