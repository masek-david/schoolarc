import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3e_widgets/m3e_widgets.dart';
import 'package:schoolarc/features/subjects/presentation/select_subject_dialog.dart';
import 'package:schoolarc/features/timetable/domain/lesson_entity_model.dart';
import 'package:schoolarc/features/timetable/domain/lesson_model.dart';
import 'package:schoolarc/features/timetable/domain/period_model.dart';
import 'package:schoolarc/features/timetable/domain/timetable_model.dart';
import 'package:schoolarc/features/timetable/presentation/edit_lesson_dialog.dart';
import 'package:schoolarc/features/timetable/presentation/edit_period_dialog.dart';
import 'package:schoolarc/features/timetable/presentation/timetable_view.dart';
import 'package:schoolarc/features/timetable/providers/timetable_notifier.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/provider/subject_notifier.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/widgets/dialogs/empty_message.dart';

class TimetableScreen extends ConsumerWidget {
  const TimetableScreen({super.key});

  void createPeriod(BuildContext context, WidgetRef ref) async {
    final period = await showDialog<Period>(
      context: context,
      builder: (context) => const EditPeriodDialog(),
    );
    if (period != null) {
      ref.read(timetableDataProvider.notifier).createPeriod(period);
    }
  }

  void editPeriod(
    BuildContext context,
    WidgetRef ref,
    Timetable timetable,
    int index,
  ) async {
    final oldPeriod = timetable.periods[index];
    final period = await showDialog<Period>(
      context: context,
      builder: (context) => EditPeriodDialog(
        initialStartTime: oldPeriod.startTime,
        initialEndTime: oldPeriod.endTime,
        initialName: oldPeriod.name,
        delete: () {
          ref.read(timetableDataProvider.notifier).deletePeriod(index);
        },
      ),
    );
    if (period != null) {
      ref
          .read(timetableDataProvider.notifier)
          .editPeriod(oldIndex: index, period: period);
    }
  }

  void createLesson(
    BuildContext context,
    WidgetRef ref,
    int weekday,
    int lessonIndex,
  ) {
    showSelectSubject(
      context: context,
      subjects: ref.read(subjectsSortedProvider),
    ).then(
      (subject) {
        if (subject != null) {
          ref
              .read(timetableDataProvider.notifier)
              .putLessonAt(
                weekday: weekday,
                index: lessonIndex,
                lesson: LessonEntity(
                  subjectId: subject.id,
                  teacher: null,
                  room: null,
                ),
              );
        }
      },
    );
  }

  void editLesson(
    BuildContext context,
    WidgetRef ref,
    int weekday,
    int lessonIndex,
    Lesson lesson,
  ) {
    showDialog(
      context: context,
      builder: (context) => EditLessonDialog(
        subjects: ref.read(subjectsSortedProvider),
        lesson: lesson,
        onSave: (lesson) {
          ref
              .read(timetableDataProvider.notifier)
              .putLessonAt(
                weekday: weekday,
                index: lessonIndex,
                lesson: lesson.toEntity(),
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showWholeWeek = ref.watch(timeTableShowWholeWeekProvider);
    final timetable = ref.watch(timetableProvider);

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
                    createPeriod(context, ref);
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
        onCreatePeriod: () => createPeriod(context, ref),
        onPeriodTapped: (lessonIndex) =>
            editPeriod(context, ref, timetable, lessonIndex),
        onLessonTapped: (weekday, lessonIndex, lesson) {
          if (lesson.isEmpty) {
            createLesson(context, ref, weekday, lessonIndex);
          } else {
            editLesson(context, ref, weekday, lessonIndex, lesson);
          }
        },
      ),
    );
  }
}
