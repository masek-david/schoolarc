import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/timetable/lesson_times_model.dart';
import 'package:schoolarc/models/timetable/timetable_entry_model.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/hw_notifier.dart';
import 'package:schoolarc/screens/main_screens/home/widgets/card_with_title.dart';
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
import 'package:schoolarc/widgets/lists/list_bottom_spacer.dart';
import 'package:schoolarc/widgets/tiles/exam_tile.dart';
import 'package:schoolarc/widgets/tiles/hw_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  bool isLessonsEmpty(List<(LessonTimes, TimetableEntry)> lessons) {
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
    DateTime timetableDateTime = showTomorrow
        ? dateToShow.toDateTimeLocal()
        : dateToShow.toDateTimeNowLocal();

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
          onRefresh: () => refreshAll(context, ref),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(8, isWide ? 24 : 0, 8, 24),
                  child: const Overview(),
                ),
                if (isRecapDate() && !hasSeenRecap())
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: RecapButton.full(context),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    if (isWide)
                      Flexible(
                        child: Column(
                          spacing: 10,
                          children: [
                            const MealsCard(),
                            TimetableCard(
                              dateToShow: timetableDateTime,
                              whenText: whenText,
                            ),
                          ],
                        ),
                      ),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!isWide) const MealsCard(),
                          if (!isWide)
                            TimetableCard(
                              dateToShow: timetableDateTime,
                              whenText: whenText,
                            ),
                          if (missedHw.isNotEmpty)
                            CardWithTitle(
                              text: context.loc.missedHomeworkTitle,
                              child: Column(
                                spacing: 8,
                                children: missedHw
                                    .map(
                                      (hw) => HwTile(
                                        hw: hw,
                                        showDate: false,
                                        onChangedCompletion: (value) =>
                                            completeHw(
                                              context,
                                              ref,
                                              hw,
                                              value,
                                            ),
                                        onDelete: () =>
                                            deleteHw(context, ref, hw),
                                        onEdit: () => editHw(context, hw),
                                        onConvert: () =>
                                            convertHw(context, ref, hw),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          if (showToday)
                            CardWithTitle(
                              text: examsToday.isEmpty && hwToday.isEmpty
                                  ? null
                                  : context.loc.today,
                              child: examsToday.isEmpty && hwToday.isEmpty
                                  ? EmptyMessage(
                                      message: context.loc.nothingPlannedFor(
                                        context.loc.today.toLowerCase(),
                                      ),
                                      asset: 'assets/confetti.svg',
                                    )
                                  : Column(
                                      spacing: 8,
                                      children: [
                                        ...examsToday.map(
                                          (e) => ExamTile(
                                            exam: e,
                                            showDeadline: false,
                                            onDelete: () =>
                                                deleteExam(context, ref, e),
                                            onEdit: () => editExam(context, e),
                                            onConvert: () => convertExam(
                                              context,
                                              ref,
                                              e,
                                            ),
                                          ),
                                        ),
                                        ...hwToday.map(
                                          (hw) => HwTile(
                                            hw: hw,
                                            showDate: false,
                                            onChangedCompletion: (value) =>
                                                completeHw(
                                                  context,
                                                  ref,
                                                  hw,
                                                  value,
                                                ),
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
                          if (showTomorrow)
                            CardWithTitle(
                              text: examsTomorrow.isEmpty && hwTomorrow.isEmpty
                                  ? null
                                  : context.loc.tomorrow,
                              child: examsTomorrow.isEmpty && hwTomorrow.isEmpty
                                  ? EmptyMessage(
                                      message: context.loc.nothingPlannedFor(
                                        context.loc.tomorrow.toLowerCase(),
                                      ),
                                      asset: 'assets/confetti.svg',
                                    )
                                  : Column(
                                      spacing: 8,
                                      children: [
                                        ...examsTomorrow.map(
                                          (e) => ExamTile(
                                            exam: e,
                                            showDeadline: false,
                                            onDelete: () =>
                                                deleteExam(context, ref, e),
                                            onEdit: () => editExam(context, e),
                                            onConvert: () => convertExam(
                                              context,
                                              ref,
                                              e,
                                            ),
                                          ),
                                        ),
                                        ...hwTomorrow.map(
                                          (hw) => HwTile(
                                            hw: hw,
                                            showDate: false,
                                            onChangedCompletion: (value) =>
                                                completeHw(
                                                  context,
                                                  ref,
                                                  hw,
                                                  value,
                                                ),
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
                          const ListBottomSpacer(),
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
