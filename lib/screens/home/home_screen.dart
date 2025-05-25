import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/models/bakalari/timetable_lesson_model.dart';
import 'package:school_manager/models/exams/exam_model.dart';
import 'package:school_manager/models/homeworks/hw_model.dart';
import 'package:school_manager/models/meal_model.dart';
import 'package:school_manager/models/timetable/lesson_times_model.dart';
import 'package:school_manager/models/timetable/timetable_model.dart';
import 'package:school_manager/provider/baka_notifier.dart';
import 'package:school_manager/provider/exam_notifier.dart';
import 'package:school_manager/provider/hw_notifier.dart';
import 'package:school_manager/screens/home/home_settings.dart';
import 'package:school_manager/screens/home/widgets/meals_card.dart';
import 'package:school_manager/screens/home/widgets/overview.dart';
import 'package:school_manager/screens/home/widgets/timetable_card.dart';
import 'package:school_manager/database/exam_database.dart';
import 'package:school_manager/database/hw_database.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/database/subject_database.dart';
import 'package:school_manager/services/home_widget_service.dart';
import 'package:school_manager/utils/extensions/datetime_extension.dart';
import 'package:school_manager/utils/screen_size.dart';
import 'package:school_manager/utils/task_functions.dart';
import 'package:school_manager/widgets/exam_list.dart';
import 'package:school_manager/widgets/homework_list.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/widgets/list_bottom_spacer.dart';
import 'package:school_manager/widgets/wide_screen_app_bar.dart';

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
        setState(() {
          bakaTimetable =
              ref.read(bakaProvider.notifier).getCurrentTimetable(dateToShow);
        });
      },
    );
  }

  Future<void> refresh() async {
    tryGettingNewHomeworks(ref);

    try {
      Future.wait([
        refreshMeals(),
        refreshTimetable(),
        if (settings.get(Setting.useFirebase)) syncAllTasks(ref),
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

  Future<void> refreshTimetable() async {
    setState(() {
      bakaTimetable =
          ref.read(bakaProvider.notifier).getCurrentTimetable(dateToShow);
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
    String whenText = showtomorrow ? 'tomorrow' : 'today';
    bool showMeals = settings.get(Setting.useMeals);
    bool showBaka = settings.get(Setting.useBakalari);

    return ValueListenableBuilder(
      valueListenable: ScreenSize.isWideScreen,
      builder: (context, isWide, child) {
        return MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          child: Scaffold(
            // only for debugging
            floatingActionButton: kDebugMode
                ? FloatingActionButton.extended(
                    onPressed: () {
                      HomeworksDatabase().deleteAllFromDisk();
                      SubjectDatabase().deleteAllFromDisk();
                      ExamDatabase().deleteAllFromDisk();
                      firebaseService.logOut();
                      ref.read(bakaProvider.notifier).logOut();
                    },
                    label: const Text('delete from disk'),
                    icon: const Icon(Icons.bug_report),
                  )
                : null,
            appBar: WideScreenAppBar(
              isWideScreen: isWide,
              leading:
                  isWide ? null : const DrawerButton(onPressed: switchDrawer),
              actions: [
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return HomeSettings(
                          onChanged: () => setState(() {}),
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.settings),
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: refresh,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ListView(
                  children: [
                    Overview(
                      hwNumberOfIncomplete: uncompletedHw,
                      examNumberOfIncomplete: upcomingExams,
                      hwNumberOfMissed: missedHw.length,
                    ),
                    SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isWide)
                          Flexible(
                              child: Column(
                            children: [
                              MealsCard(
                                isVisible: showMeals,
                                meals: mealsFuture,
                                refresh: refreshMeals,
                              ),
                              TimetableCard(
                                refresh: refreshTimetable,
                                defaultTimeTable: defaultTimeTable,
                                bakaTimetable: bakaTimetable,
                                dateToShow: dateToShow,
                                whenText: whenText,
                                showOnline: showBaka,
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
                                  isVisible: showMeals,
                                  meals: mealsFuture,
                                  refresh: refreshMeals,
                                ),
                              if (!isWide)
                                TimetableCard(
                                  refresh: refreshTimetable,
                                  defaultTimeTable: defaultTimeTable,
                                  bakaTimetable: bakaTimetable,
                                  dateToShow: dateToShow,
                                  whenText: whenText,
                                  showOnline: showBaka,
                                ),
                              if (missedHw.isNotEmpty)
                                Card(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerLowest,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: HomeworkList(
                                      onChangedCompletion: (hw, value) =>
                                          completeHw(context, ref, hw, value),
                                      onDelete: (hw) =>
                                          deleteHw(context, ref, hw),
                                      onConvert: (hw) =>
                                          convertHw(context, ref, hw),
                                      onEdit: (hw) => editHw(context, ref, hw),
                                      textFull: 'Missed homeworks',
                                      showText: true,
                                      showDates: true,
                                      hwList: missedHw,
                                    ),
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
                                    onEdit: (exam) =>
                                        editExam(context, ref, exam),
                                    onConvert: (exam) =>
                                        convertExam(context, ref, exam),
                                    textFull: 'Exams $whenText',
                                    showText: true,
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
                                    onChangedCompletion: (hw, value) =>
                                        completeHw(context, ref, hw, value),
                                    onDelete: (hw) =>
                                        deleteHw(context, ref, hw),
                                    onEdit: (hw) => editHw(context, ref, hw),
                                    onConvert: (hw) =>
                                        convertHw(context, ref, hw),
                                    textFull: 'Homeworks $whenText',
                                    showText: true,
                                    showDates: false,
                                    hwList: hwToShow,
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
      },
    );
  }
}
