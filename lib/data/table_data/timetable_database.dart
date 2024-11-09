import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:school_manager/data/subjects_data/subject_dto_model.dart';
import 'package:school_manager/data/subjects_data/subject_service.dart';
import 'package:school_manager/data/table_data/lesson_times_model.dart';
import 'package:school_manager/data/table_data/table_dto_model.dart';
import 'package:school_manager/data/table_data/table_model.dart';
import 'package:school_manager/extensions/timeofday_extension.dart';

class TimeTableDatabase {
  final _tableBox = Hive.box('tableBox');
  late TimeTable _table = _tableBox.get(tableKey);
  late final _subjectService = SubjectService();
  final String tableKey = 'table';

  TimeTableDTO get timeTable {
    final tempTable = _tableBox.get(tableKey);
    if (tempTable == null) {
      _tableBox.put(tableKey, TimeTable.empty());
      _table = TimeTable.empty();
    } else {
      _table = tempTable as TimeTable;
    }

    var subjects = _subjectService.getMap();

    return _table.convertToDTO(subjects);
  }

  Map<LessonTimes, SubjectDTO?> get upcomingLessons {
    Map<LessonTimes, SubjectDTO?> upcomingLessons = {};

    final timetable = timeTable;
    final now = DateTime.now();
    Map<int, LessonTimes> upcomingLessonTimes = {};

    for (int i = 0; i < timetable.lessonTimes.length; i++) {
      final lesson = timetable.lessonTimes[i];

      if (TimeOfDay(hour: now.hour, minute: now.minute)
          .isBefore(lesson.endTime)) {
        upcomingLessonTimes.addAll({i: lesson});
      }
    }

    for (var lessonIndex in upcomingLessonTimes.keys) {
      upcomingLessons.addAll({
        upcomingLessonTimes[lessonIndex]!: timetable.table[now.weekday - 1]
            [lessonIndex]
      });
    }

    return upcomingLessons;
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
