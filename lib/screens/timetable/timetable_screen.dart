import 'package:flutter/material.dart';
import 'package:school_manager/data/settings_database.dart';
import 'package:school_manager/data/subjects_data/subject_service.dart';
import 'package:school_manager/data/table_data/lesson_times_model.dart';
import 'package:school_manager/data/table_data/timetable_database.dart';
import 'package:school_manager/screens/timetable/new_lesson_times.dart';
import 'package:school_manager/screens/timetable/select_subject.dart';
import 'package:school_manager/screens/timetable/timetable_settings.dart';
import 'package:school_manager/screens/timetable/widgets/timetable_view.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  late final _db = TimeTableDatabase();
  late final _subjectService = SubjectService();
  late final _settings = SettingsDatabase();

  late var timeTable = _db.timeTable;

  late double columnWidth = _settings.get(Setting.timeTableTileWidth);
  late bool showWholeWeek = _settings.get(Setting.timeTableShowWholeWeek);

  void updateView() {
    setState(() {
      timeTable = _db.timeTable;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return TimetableSettings(
                    showWholeWeek: showWholeWeek,
                    tileWidth: columnWidth,
                    changeShowWholeWeek: (value) {
                      setState(() {
                        showWholeWeek = value;
                        _settings.save(Setting.timeTableShowWholeWeek, value);
                      });
                    },
                    changeTileWidth: (width) {
                      setState(() {
                        columnWidth = width;
                        _settings.save(Setting.timeTableTileWidth, width);
                      });
                    },
                  );
                },
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add new lesson time',
        onPressed: () {
          showDialog<LessonTimes>(
            context: context,
            builder: (context) {
              return const NewLessonTimes();
            },
          ).then(
            (lessonTimes) {
              if (lessonTimes != null) {
                _db.newLessonTime(lessonTimes);
                updateView();
              }
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: TimetableView(
        timeTable: timeTable,
        showWholeWeek: showWholeWeek,
        columnWidth: columnWidth,
        onLessonTimesTapped: (lessonTimes, lessonIndex) {
          showDialog<LessonTimes>(
            context: context,
            builder: (context) {
              return NewLessonTimes(
                initialStartTime: lessonTimes.startTime,
                initialEndTime: lessonTimes.endTime,
                initialName: lessonTimes.name,
                delete: () {
                  _db.deleteLessonTime(lessonIndex);
                  updateView();
                },
              );
            },
          ).then(
            (value) {
              if (lessonTimes != value && value != null) {
                _db.editLessonTime(lessonIndex, value);
                updateView();
              }
            },
          );
        },
        onSubjectTapped: (weekday, lessonIndex, lesson) {
          showSelectSubject(
              context: context,
              subjects: _subjectService.getSortedList(),
              delete: () {
                _db.deleteLessonAt(weekday, lessonIndex);
                updateView();
              }).then(
            (value) {
              if (value != null) {
                _db.newLessonAt(
                  weekday,
                  lessonIndex,
                  value.dbIndex,
                );
                updateView();
              }
            },
          );
        },
      ),
    );
  }
}
