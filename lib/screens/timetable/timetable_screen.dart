import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/models/timetable/lesson_times_model.dart';
import 'package:schoolarc/provider/subject_notifier.dart';
import 'package:schoolarc/screens/timetable/new_lesson_times.dart';
import 'package:schoolarc/screens/timetable/select_subject.dart';
import 'package:schoolarc/screens/timetable/timetable_settings.dart';
import 'package:schoolarc/screens/timetable/widgets/timetable_view.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/dialogs/empty_message.dart';

class TimetableScreen extends ConsumerStatefulWidget {
  const TimetableScreen({super.key});

  @override
  ConsumerState<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends ConsumerState<TimetableScreen> {
  late var timeTable = timetableDb.timeTable;

  late double columnWidth = settings.get(Setting.timeTableTileWidth);
  late bool showWholeWeek = settings.get(Setting.timeTableShowWholeWeek);

  void updateView() {
    setState(() {
      timeTable = timetableDb.timeTable;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.timetable),
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
                        settings.save(Setting.timeTableShowWholeWeek, value);
                      });
                    },
                    changeTileWidth: (width) {
                      setState(() {
                        columnWidth = width;
                        settings.save(Setting.timeTableTileWidth, width);
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
        tooltip: context.loc.addNewLessonTime,
        onPressed: () {
          showDialog<LessonTimes>(
            context: context,
            builder: (context) {
              return const NewLessonTimes();
            },
          ).then(
            (lessonTimes) {
              if (lessonTimes != null) {
                timetableDb.newLessonTime(lessonTimes);
                updateView();
              }
            },
          );
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: TimetableView(
        timeTable: timeTable,
        contentWhenEmpty: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            EmptyMessage(message: context.loc.noTimetableMessage),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).restorablePushNamed('/bakalari'),
              child: Text(context.loc.bakalari),
            ),
          ],
        ),
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
                  timetableDb.deleteLessonTime(lessonIndex);
                  updateView();
                },
              );
            },
          ).then(
            (value) {
              if (lessonTimes != value && value != null) {
                timetableDb.editLessonTime(lessonIndex, value);
                updateView();
              }
            },
          );
        },
        onSubjectTapped: (weekday, lessonIndex, lesson) {
          showSelectSubject(
            context: context,
            subjects: ref.read(subjectsSortedProvider),
            delete: () {
              timetableDb.deleteLessonAt(weekday, lessonIndex);
              updateView();
            },
          ).then(
            (value) {
              if (value != null) {
                timetableDb.newLessonAt(
                  weekday,
                  lessonIndex,
                  value.id,
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
