import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/models/bakalari/timetable_lesson_model.dart';
import 'package:schoolarc/models/timetable/lesson_times_model.dart';
import 'package:schoolarc/provider/bakalari/baka_homeworks_notifier.dart';
import 'package:schoolarc/provider/bakalari/current_timetable_notifier.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/hw_notifier.dart';
import 'package:schoolarc/provider/strava/strava_meals_notifier.dart';
import 'package:schoolarc/provider/use_cloudsync_notifier.dart';
import 'package:schoolarc/screens/main_screens/home/widgets/meals_card.dart';
import 'package:schoolarc/screens/main_screens/home/widgets/overview.dart';
import 'package:schoolarc/screens/main_screens/home/widgets/timetable_card.dart';
import 'package:schoolarc/screens/recap/recap_button.dart';
import 'package:schoolarc/screens/recap/recap_screen.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/datetime_extension.dart';
import 'package:schoolarc/utils/extensions/string_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/utils/task_functions.dart';
import 'package:schoolarc/widgets/dialogs/empty_message.dart';
import 'package:schoolarc/widgets/lists/homework_list.dart';
import 'package:schoolarc/widgets/lists/list_bottom_spacer.dart';
import 'package:schoolarc/widgets/tiles/exam_tile.dart';
import 'package:schoolarc/widgets/tiles/hw_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> refresh(BuildContext context, WidgetRef ref) async {
    try {
      await Future.wait([
        ref.read(bakaHomeworksProvider.notifier).refresh(),
        ref.read(stravaMealsProvider.notifier).refresh(),
        ref.read(currentTimetableProvider.notifier).refresh(),
        if (ref.read(useCloudSyncProvider)) syncAllTasks(ref),
      ]);
    } on Object catch (e) {
      if (context.mounted) {
        showMessage(context, e.toString(), isError: true);
      }
    }
    return;
  }

  bool isLessonsEmpty(Map<LessonTimes, TimeTableLesson> lessons) {
    bool isEmpty = true;
    lessons.forEach(
      (lessonTimes, lesson) {
        if (!lesson.isEmpty) {
          isEmpty = false;
        }
      },
    );
    return isEmpty;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hws = ref.watch(hwDatesProvider);
    final missedHw = ref.watch(hwMissedProvider);
    final int uncompletedHw = ref.watch(hwProvider).values.where(
      (element) {
        return !element.isDeleted &&
            !element.isCompleted &&
            !element.deadline.isBeforeToday();
      },
    ).length;
    final exams = ref.watch(examsDatesProvider);
    final int upcomingExams = ref.watch(examProvider).values.where(
      (element) {
        return !element.isDeleted && !element.isCompleted;
      },
    ).length;

    var dateToShow = DateTime.now();
    final defaultTimeTable = timetableDb.timeTable;
    var upcomingLessons = defaultTimeTable.getUpcomingLessons(dateToShow);

    bool showtomorrow = isLessonsEmpty(upcomingLessons);
    if (showtomorrow) {
      dateToShow = DateTime.utc(dateToShow.toUtc().year,
              dateToShow.toUtc().month, dateToShow.toUtc().day, 0, 0)
          .add(const Duration(days: 1))
          .toLocal();
    }
    final dateToShowOnlyDate = dateToShow.onlyDate();
    final hwToShow = hws[dateToShowOnlyDate] ?? [];
    final examsToShow = exams[dateToShowOnlyDate] ?? [];

    String whenText = showtomorrow
        ? context.loc.tomorrow.toLowerCase()
        : context.loc.today.toLowerCase();

    final isWide = context.isWide;

    return MediaQuery.removePadding(
      context: context,
      removeBottom: true,
      child: Container(
        color: context.col.surface,
        child: RefreshIndicator(
          onRefresh: () => refresh(context, ref),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView(
              children: [
                const SizedBox(height: 16),
                Overview(
                  hwNumberOfIncomplete: uncompletedHw,
                  examNumberOfIncomplete: upcomingExams,
                  hwNumberOfMissed: missedHw.length,
                ),
                if (isRecapDate() && !hasSeenRecap())
                  RecapButton(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${context.loc.anotherYearBehind} 🎉',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(context.loc.viewYearStats),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isWide)
                      Flexible(
                          child: Column(
                        children: [
                          const MealsCard(),
                          TimetableCard(
                            dateToShow: dateToShow,
                            whenText: whenText,
                          ),
                        ],
                      )),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!isWide) const MealsCard(),
                          if (!isWide)
                            TimetableCard(
                              dateToShow: dateToShow,
                              whenText: whenText,
                            ),
                          if (missedHw.isNotEmpty)
                            Card(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerLowest,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: HomeworkList(
                                    hwList: missedHw,
                                    onChangedCompletion: (hw, value) =>
                                        completeHw(context, ref, hw, value),
                                    onDelete: (hw) => deleteHw(context, ref, hw),
                                    onConvert: (hw) =>
                                        convertHw(context, ref, hw),
                                    onEdit: (hw) => editHw(context, hw),
                                    showDates: true,
                                    text: context.loc.missedHomework(2)),
                              ),
                            ),
                          Card(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerLowest,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: examsToShow.isEmpty && hwToShow.isEmpty
                                  ? EmptyMessage(
                                      message:
                                          context.loc.nothingPlannedFor(whenText),
                                      asset: 'assets/confetti.svg',
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      spacing: 8,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            whenText.capitalize(),
                                            style: context.txt.bodyLarge,
                                          ),
                                        ),
                                        ...examsToShow.map(
                                          (e) => ExamTile(
                                            exam: e,
                                            showDeadline: false,
                                            onDelete: () =>
                                                deleteExam(context, ref, e),
                                            onEdit: () => editExam(context, e),
                                            onConvert: () =>
                                                convertExam(context, ref, e),
                                          ),
                                        ),
                                        ...hwToShow.map(
                                          (hw) => HwTile(
                                            hw: hw,
                                            showDate: false,
                                            onChangedCompletion: (value) =>
                                                completeHw(
                                                    context, ref, hw, value),
                                            onDelete: () =>
                                                deleteHw(context, ref, hw),
                                            onEdit: () => editHw(context, hw),
                                            onConvert: () =>
                                                convertHw(context, ref, hw),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          const ListBottomSpacer()
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
