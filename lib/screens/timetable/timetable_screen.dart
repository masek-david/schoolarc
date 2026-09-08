import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3e_widgets/m3e_widgets.dart';
import 'package:schoolarc/features/timetable/presentation/edit_period_dialog.dart';
import 'package:schoolarc/models/timetable/lesson_times_model.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/provider/subject_notifier.dart';
import 'package:schoolarc/screens/timetable/select_subject.dart';
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
  late var timetable = timetableDb.timeTable;

  void updateView() {
    setState(() {
      timetable = timetableDb.timeTable;
    });
  }

  void createPeriod(int index) async {
    final period = await showDialog<LessonTimes>(
      context: context,
      builder: (context) => const EditPeriodDialog(),
    );
    if (period != null) {
      timetableDb.newLessonTime(period);
      updateView();
    }
  }

  void editPeriod(int index) async {
    final oldPeriod = timetable.lessonTimes[index];
    final period = await showDialog<LessonTimes>(
      context: context,
      builder: (context) => EditPeriodDialog(
        initialStartTime: oldPeriod.startTime,
        initialEndTime: oldPeriod.endTime,
        initialName: oldPeriod.name,
        delete: () {
          timetableDb.deleteLessonTime(index);
          updateView();
        },
      ),
    );
    if (period != null) {
      timetableDb.editLessonTime(index, period);
      updateView();
    }
  }

  @override
  Widget build(BuildContext context) {
    final showWholeWeek = ref.watch(timeTableShowWholeWeekProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.timetable),
      ),
      body: TimetableView(
        timeTable: timetable,
        contentWhenEmpty: Column(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            EmptyMessage(message: context.loc.noTimetableMessage),
            M3EToggleButtonGroup(
              selectedIndex: 0,
              onSelectedIndexChanged: (value) {
                switch (value) {
                  case null:
                    createPeriod(0);
                  case 1:
                    Navigator.of(context).restorablePushNamed('/bakalari');
                }
              },
              style: .filled,
              size: .md,
              actions: [
                const M3EToggleButtonGroupAction(icon: Icon(Icons.add_rounded)),
                M3EToggleButtonGroupAction(
                  label: Text(context.loc.import),
                  icon: const Icon(Icons.download_rounded),
                ),
              ],
            ),
          ],
        ),
        showWholeWeek: showWholeWeek,
        onCreatePeriod: createPeriod,
        onLessonTimesTapped: editPeriod,
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
