import 'package:hive/hive.dart';
import 'package:school_manager/data/bakalari/timetable_lesson_model.dart';
import 'package:school_manager/data/table_data/lesson_times_model.dart';
import 'package:school_manager/data/table_data/table_dto_model.dart';
import 'package:school_manager/data/table_data/table_model.dart';
import 'package:school_manager/extensions/timeofday_extension.dart';
import 'package:school_manager/tasks_app.dart';

class TimeTableDatabase {
  final _tableBox = Hive.box('tableBox');
  late TimeTable _table = _tableBox.get(tableKey);
  final String tableKey = 'table';

  TimeTableDTO get timeTable {
    final tempTable = _tableBox.get(tableKey);
    if (tempTable == null) {
      _tableBox.put(tableKey, TimeTable.empty());
      _table = TimeTable.empty();
    } else {
      _table = tempTable as TimeTable;
    }

    var subjects = subjectService.getMap();

    return _table.convertToDTO(subjects);
  }

  @Deprecated('use  getUpcomingLessons method of timetableDTO')
  Map<LessonTimes, TimeTableLesson> get upcomingLessons {
    return timeTable.getUpcomingLessons(DateTime.now());
  }

  /// overwrites old table
  void createTable(List<LessonTimes> lessonTimes) {
    _table = TimeTable(lessonTimes);
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

  void newLessonAt(int weekday, int lessonIndex, int subjectIndex) {
    _table = _tableBox.get(tableKey);
    _table.table[weekday][lessonIndex] = subjectIndex;

    _tableBox.put(tableKey, _table);
  }

  void deleteLessonAt(int weekday, int lessonIndex) {
    _table = _tableBox.get(tableKey);
    _table.table[weekday][lessonIndex] = null;

    _tableBox.put(tableKey, _table);
  }
}
