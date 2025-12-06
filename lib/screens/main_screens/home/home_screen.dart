import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/models/bakalari/timetable_lesson_model.dart';
import 'package:schoolarc/models/date/date.dart';
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
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/utils/task_functions.dart';
import 'package:schoolarc/widgets/dialogs/empty_message.dart';
import 'package:schoolarc/widgets/expressive_loading/expressive_refresh_indicator.dart';
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

  bool isLessonsEmpty(List<(LessonTimes, TimeTableLesson)> lessons) {
    bool isEmpty = true;
    for (var value in lessons) {
      if (!value.$2.isEmpty) {
        isEmpty = false;
      }
    }
    return isEmpty;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hws = ref.watch(hwDatesProvider);
    final missedHw = ref.watch(hwMissedProvider);
    final exams = ref.watch(examsDatesProvider);

    final defaultTimeTable = timetableDb.timeTable;
    var upcomingLessons = defaultTimeTable.getUpcomingLessons(DateTime.now());

    final hwToday = hws[Date.today()] ?? [];
    final examsToday = exams[Date.today()] ?? [];
    final hwTomorrow = hws[Date.today().addDays(1)] ?? [];
    final examsTomorrow = exams[Date.today().addDays(1)] ?? [];

    // If tomorrow card is shown
    final showTomorrow = isLessonsEmpty(upcomingLessons);
    final dateToShow = showTomorrow ? Date.today().addDays(1) : Date.today();

    final allTodayHwsAreCompleted = hwToday
        .where((element) => !element.isCompleted || element.isBeingAnimated)
        .isNotEmpty;
    // if today card is shown
    final showToday = !showTomorrow || allTodayHwsAreCompleted;

    // we need the time so we can show timetable for now or for tomorrow whole day
    DateTime timetableDateTime = dateToShow.toDateTimeNowLocal();

    String whenText = showTomorrow
        ? context.loc.tomorrow.toLowerCase()
        : context.loc.today.toLowerCase();

    final isWide = context.isWide;

    return MediaQuery.removePadding(
      context: context,
      removeBottom: true,
      child: Container(
        color: context.col.surface,
        child: ExpressiveRefreshIndicator(
          onRefresh: () => refresh(context, ref),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView(
              children: [
                const SizedBox(height: 16),
                const Overview(),
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
                            dateToShow: timetableDateTime,
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
                              dateToShow: timetableDateTime,
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
                                  text: context.loc.missedHomeworkTitle,
                                ),
                              ),
                            ),
                          if (showToday)
                            Card(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerLowest,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: examsToday.isEmpty && hwToday.isEmpty
                                    ? EmptyMessage(
                                        message: context.loc.nothingPlannedFor(
                                            context.loc.today.toLowerCase()),
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
                                              context.loc.today,
                                              style: context.txt.bodyLarge,
                                            ),
                                          ),
                                          ...examsToday.map(
                                            (e) => ExamTile(
                                              exam: e,
                                              showDeadline: false,
                                              onDelete: () =>
                                                  deleteExam(context, ref, e),
                                              onEdit: () =>
                                                  editExam(context, e),
                                              onConvert: () =>
                                                  convertExam(context, ref, e),
                                            ),
                                          ),
                                          ...hwToday.map(
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
                          if (showTomorrow)
                            Card(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerLowest,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: examsTomorrow.isEmpty &&
                                        hwTomorrow.isEmpty
                                    ? EmptyMessage(
                                        message: context.loc.nothingPlannedFor(
                                            context.loc.tomorrow.toLowerCase()),
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
                                              context.loc.tomorrow,
                                              style: context.txt.bodyLarge,
                                            ),
                                          ),
                                          ...examsTomorrow.map(
                                            (e) => ExamTile(
                                              exam: e,
                                              showDeadline: false,
                                              onDelete: () =>
                                                  deleteExam(context, ref, e),
                                              onEdit: () =>
                                                  editExam(context, e),
                                              onConvert: () =>
                                                  convertExam(context, ref, e),
                                            ),
                                          ),
                                          ...hwTomorrow.map(
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
