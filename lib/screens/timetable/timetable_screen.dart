import 'package:flutter/material.dart';
import 'package:school_manager/data/settings_database.dart';
import 'package:school_manager/data/subjects_data/subject_service.dart';
import 'package:school_manager/data/table_data/lesson_times_model.dart';
import 'package:school_manager/data/table_data/timetable_database.dart';
import 'package:school_manager/screens/timetable/new_lesson_times.dart';
import 'package:school_manager/screens/timetable/select_subject.dart';
import 'package:school_manager/screens/timetable/timetable_settings.dart';
import 'package:school_manager/screens/timetable/widgets/timetable_subject.dart';

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
  late bool showName = _settings.get(Setting.timeTableShowName);

  void updateView() {
    setState(() {
      timeTable = _db.timeTable;
    });
  }

  @override
  Widget build(BuildContext context) {
    var table = timeTable.table;
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
                    showSubjectNames: showName,
                    changeShowSubjectName: (value) {
                      setState(() {
                        showName = value;
                        _settings.save(Setting.timeTableShowName, value);
                      });
                    },
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
      body: timeTable.lessonTimes.isEmpty
          ? const Center(
              child: Text(
                'No timetable found. You can create new timetable by tapping the plus button.',
                textAlign: TextAlign.center,
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 8,
                  bottom: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    showWholeWeek ? table.length + 1 : table.length - 2 + 1,
                    (rowIndex) {
                      if (rowIndex == 0) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                            timeTable.lessonTimes.length,
                            (lessonIndex) {
                              final lessonTimes =
                                  timeTable.lessonTimes[lessonIndex];

                              return Padding(
                                padding: const EdgeInsets.all(4),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  width: columnWidth,
                                  child: InkWell(
                                    onTap: () {
                                      showDialog<LessonTimes>(
                                        context: context,
                                        builder: (context) {
                                          return NewLessonTimes(
                                            initialStartTime:
                                                lessonTimes.startTime,
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
                                          if (lessonTimes != value &&
                                              value != null) {
                                            _db.editLessonTime(
                                                lessonIndex, value);
                                            updateView();
                                          }
                                        },
                                      );
                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          lessonTimes.name,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          textAlign: TextAlign.center,
                                          lessonTimes
                                              .toStringFormatted(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                      int weekday = rowIndex - 1;
                      return Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: List.generate(
                            table[weekday].length,
                            (lessonIndex) {
                              final subject = table[weekday][lessonIndex];

                              bool isHighlighted =
                                  timeTable.lessonTimes[lessonIndex].isActive &&
                                      DateTime.now().weekday - 1 == weekday;

                              return TimetableSubject(
                                isHighlighted: isHighlighted,
                                subject: subject,
                                columnWidth: columnWidth,
                                onTap: () {
                                  showSelectSubject(
                                      context: context,
                                      subjects: _subjectService.getSortedList(),
                                      delete: () {
                                        _db.deleteLessonAt(
                                            weekday, lessonIndex);
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
                                showName: showName,
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
    );
  }
}
