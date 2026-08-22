import 'package:hive_ce/hive.dart';
import 'package:schoolarc/database/hive/hive_init.dart';
import 'package:schoolarc/mock_data/mock_data.dart';
import 'package:schoolarc/models/timetable/lesson_times_model.dart';
import 'package:schoolarc/models/timetable/timetable_entity_model.dart';
import 'package:schoolarc/models/timetable/timetable_model.dart';
import 'package:schoolarc/utils/extensions/timeofday_extension.dart';
import 'package:schoolarc/utils/globals.dart';

class TimeTableDatabase {
  final _tableBox = Hive.box(tableBox);
  static const String tableKey = 'table';
  late TimeTableEntity _table;

  TimeTableDatabase() {
    final TimeTableEntity? tempTable = _tableBox.get(tableKey);
    if (tempTable == null) {
      final emptyTimeTable = TimeTableEntity(null, null);
      _tableBox.put(tableKey, emptyTimeTable);
      _table = emptyTimeTable;
    } else {
      _table = tempTable;
    }
  }

  Timetable get timeTable {
    if (MockData.useMock) {
      return MockData.timetable;
    }

    var subjects = subjectsDb.readDatabase();

    return _table.convert(subjects);
  }

  void overrideTable(TimeTableEntity table) {
    _table = table;
    _tableBox.put(tableKey, _table);
  }

  /// overwrites old table
  void createTable(List<LessonTimes> lessonTimes) {
    _table = TimeTableEntity(lessonTimes, null);
    _tableBox.put(tableKey, _table);
  }

  void newLessonTime(LessonTimes lesson) {
    late int indexOfLessonInList = _table.lessonTimes.length;
    for (int i = 0; i < _table.lessonTimes.length; i++) {
      if (lesson.startTime.toDateTime().isBefore(
        _table.lessonTimes[i].startTime.toDateTime(),
      )) {
        indexOfLessonInList = i;
        break;
      }
    }

    _table.lessonTimes.insert(indexOfLessonInList, lesson);
    for (var day in _table.table) {
      day.insert(indexOfLessonInList, null);
    }

    _tableBox.put(tableKey, _table);
  }

  void deleteLessonTime(int index) {
    _table.lessonTimes.removeAt(index);
    for (var day in _table.table) {
      day.removeAt(index);
    }

    _tableBox.put(tableKey, _table);
  }

  void editLessonTime(int oldIndex, LessonTimes newLessonTime) {
    _table.lessonTimes.removeAt(oldIndex);

    late int newIndex = _table.lessonTimes.length;
    for (int i = 0; i < _table.lessonTimes.length; i++) {
      if (newLessonTime.startTime.toDateTime().isBefore(
        _table.lessonTimes[i].startTime.toDateTime(),
      )) {
        newIndex = i;
        break;
      }
    }

    _table.lessonTimes.insert(newIndex, newLessonTime);

    for (var day in _table.table) {
      day.insert(newIndex, day.removeAt(oldIndex));
    }

    _tableBox.put(tableKey, _table);
  }

  void newLessonAt(int weekday, int lessonIndex, String? subjectId) {
    _table = _tableBox.get(tableKey);
    _table.table[weekday][lessonIndex] = subjectId;

    _tableBox.put(tableKey, _table);
  }

  void deleteLessonAt(int weekday, int lessonIndex) {
    _table = _tableBox.get(tableKey);
    _table.table[weekday][lessonIndex] = null;

    _tableBox.put(tableKey, _table);
  }
}
