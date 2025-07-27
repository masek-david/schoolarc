import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/models/bakalari/timetable_lesson_model.dart';
import 'package:schoolarc/models/exams/exam_model.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/models/meal_model.dart';
import 'package:schoolarc/models/timetable/lesson_times_model.dart';
import 'package:schoolarc/models/timetable/timetable_model.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/hw_notifier.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/provider/use_cloudsync_notifier.dart';
import 'package:schoolarc/screens/main_screens/home/home_settings.dart';
import 'package:schoolarc/screens/main_screens/home/widgets/meals_card.dart';
import 'package:schoolarc/screens/main_screens/home/widgets/overview.dart';
import 'package:schoolarc/screens/main_screens/home/widgets/timetable_card.dart';
import 'package:schoolarc/screens/recap/recap_button.dart';
import 'package:schoolarc/screens/recap/recap_screen.dart';
import 'package:schoolarc/services/home_widget_service.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/datetime_extension.dart';
import 'package:schoolarc/utils/extensions/string_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/utils/task_functions.dart';
import 'package:schoolarc/widgets/exam_list.dart';
import 'package:schoolarc/widgets/homework_list.dart';
import 'package:schoolarc/widgets/list_bottom_spacer.dart';
import 'package:schoolarc/widgets/wide_screen_app_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  var dateToShow = DateTime.now();

  late TimeTable defaultTimeTable = timetableDb.timeTable;
  Future<TimeTable?>? bakaTimetable;
  late Future<Map<DateTime, List<Meal>>>? mealsFuture;

  @override
  void initState() {
    super.initState();

    mealsFuture = stravaService.getMeals().then(
      (value) {
        updateStravaWidget(value);
        return value;
      },
    );

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        refreshTimetable(ref);
      },
    );
  }

  Future<void> refresh(BuildContext context) async {
    tryGettingNewHomeworks(context);

    try {
      Future.wait([
        refreshMeals(),
        refreshTimetable(ref),
        if (ref.watch(useCloudSyncProvider)) syncAllTasks(ref),
      ]);
    } on Object catch (e) {
      showMessage(context, e.toString(), isError: true);
    }

    return;
  }

  Future<void> refreshMeals() async {
    setState(() {
      mealsFuture = stravaService.getMeals();
    });

    try {
      final meals = await mealsFuture;

      if (meals != null) {
        updateStravaWidget(meals);
      }
    } catch (_) {}

    return;
  }

  Future<void> refreshTimetable(WidgetRef ref) async {
    setState(() {
      bakaTimetable = bakaService.getCurrentTimetable(dateToShow, ref);
    });

    try {
      await bakaTimetable;
    } catch (_) {}

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
  Widget build(BuildContext context) {
    final hws = ref.watch(hwDatesProvider);
    final missedHw = ref.watch(hwMissedProvider);
    final exams = ref.watch(examsDatesProvider);
    final uncompletedHw = ref.watch(hwProvider).values.where(
      (element) {
        return !element.isDeleted &&
            !element.isCompleted &&
            !element.deadline.isBeforeToday();
      },
    ).length;
    final upcomingExams = ref.watch(examProvider).values.where(
      (element) {
        return !element.isDeleted && !element.isCompleted;
      },
    ).length;

    List<Homework> hwToShow = [];
    List<Exam> examToShow = [];

    dateToShow = DateTime.now();
    var upcomingLessons = defaultTimeTable.getUpcomingLessons(dateToShow);

    bool showtomorrow = isLessonsEmpty(upcomingLessons);
    if (showtomorrow) {
      dateToShow = DateTime.utc(dateToShow.toUtc().year,
              dateToShow.toUtc().month, dateToShow.toUtc().day, 0, 0)
          .add(const Duration(days: 1))
          .toLocal();

      final dateToShowOnlyDate = dateToShow.onlyDate();

      upcomingLessons = defaultTimeTable.getUpcomingLessons(dateToShow);
      hwToShow = hws[dateToShowOnlyDate] ?? [];
      examToShow = exams[dateToShowOnlyDate] ?? [];
    } else {
      final dateToShowOnlyDate = dateToShow.onlyDate();
      hwToShow = hws[dateToShowOnlyDate] ?? [];
      examToShow = exams[dateToShowOnlyDate] ?? [];
    }
    String whenText = showtomorrow
        ? context.loc.tomorrow.toLowerCase()
        : context.loc.today.toLowerCase();
    bool showBaka = ref.watch(useBakaProvider);

    final isWide = context.isWide;

    return MediaQuery.removePadding(
      context: context,
      removeBottom: true,
      child: Scaffold(
        appBar: WideScreenAppBar(
          isWideScreen: isWide,
          actions: [
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return const HomeSettings();
                  },
                );
              },
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => refresh(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView(
              children: [
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
                          MealsCard(
                            meals: mealsFuture,
                            refresh: refreshMeals,
                          ),
                          TimetableCard(
                            refresh: () => refreshTimetable(ref),
                            defaultTimeTable: defaultTimeTable,
                            bakaTimetable: bakaTimetable,
                            dateToShow: dateToShow,
                            whenText: whenText,
                            showOnline: showBaka,
                            ref: ref,
                          ),
                        ],
                      )),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!isWide)
                            MealsCard(
                              meals: mealsFuture,
                              refresh: refreshMeals,
                            ),
                          if (!isWide)
                            TimetableCard(
                              refresh: () => refreshTimetable(ref),
                              defaultTimeTable: defaultTimeTable,
                              bakaTimetable: bakaTimetable,
                              dateToShow: dateToShow,
                              whenText: whenText,
                              showOnline: showBaka,
                              ref: ref,
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
                                    onDelete: (hw) =>
                                        deleteHw(context, ref, hw),
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
                              padding: const EdgeInsets.all(12),
                              child: ExamList(
                                onDelete: (exam) =>
                                    deleteExam(context, ref, exam),
                                onEdit: (exam) => editExam(context, exam),
                                onConvert: (exam) =>
                                    convertExam(context, ref, exam),
                                text: context.loc
                                    .examsFor(
                                      examToShow.isEmpty.toString(),
                                      whenText,
                                    )
                                    .capitalize(),
                                showDates: false,
                                examList: examToShow,
                              ),
                            ),
                          ),
                          Card(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerLowest,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: HomeworkList(
                                hwList: hwToShow,
                                onChangedCompletion: (hw, value) =>
                                    completeHw(context, ref, hw, value),
                                onDelete: (hw) => deleteHw(context, ref, hw),
                                onEdit: (hw) => editHw(context, hw),
                                onConvert: (hw) => convertHw(context, ref, hw),
                                showDates: false,
                                text: context.loc
                                    .homeworksFor(
                                      hwToShow.isEmpty.toString(),
                                      whenText,
                                    )
                                    .capitalize(),
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
