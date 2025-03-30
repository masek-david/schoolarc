
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/models/bakalari/timetable_lesson_model.dart';
import 'package:school_manager/models/exams/exam_dto_model.dart';
import 'package:school_manager/models/homeworks/hw_dto_model.dart';
import 'package:school_manager/models/meal_model.dart';
import 'package:school_manager/models/timetable/lesson_times_model.dart';
import 'package:school_manager/models/timetable/timetable_dto_model.dart';
import 'package:school_manager/provider/exam_notifier.dart';
import 'package:school_manager/provider/hw_notifier.dart';
import 'package:school_manager/screens/home/home_settings.dart';
import 'package:school_manager/screens/home/widgets/meals_card.dart';
import 'package:school_manager/screens/home/widgets/overview.dart';
import 'package:school_manager/screens/home/widgets/timetable_card.dart';
import 'package:school_manager/services/exams/exam_database.dart';
import 'package:school_manager/services/homeworks/hw_database.dart';
import 'package:school_manager/services/settings_database.dart';
import 'package:school_manager/services/subjects/subject_database.dart';
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
  late var dateToShow = DateTime.now();

  late TimeTableDTO defaultTimeTable = timetableDatabase.timeTable;
  Future<TimeTableDTO?>? bakaTimetable;
  late Future<Map<DateTime, List<Meal>>>? mealsFuture;

  @override
  void initState() {
    super.initState();

    bakaTimetable = bakaService.getCurrentTimetable(DateTime.now(), ref);
    mealsFuture = stravaService.getMeals().then(
      (value) {
        updateStravaWidget(value);
        return value;
      },
    );
  }

  Future<void> refresh() async {
    tryGettingNewHomeworks();

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

    List<HomeworkDTO> hwToShow = [];
    List<ExamDTO> examToShow = [];

    dateToShow = DateTime.now();
    var upcomingLessons = defaultTimeTable.getUpcomingLessons(dateToShow);

    bool showTommorrow = isLessonsEmpty(upcomingLessons);
    if (showTommorrow) {
      dateToShow = DateTime.utc(dateToShow.toUtc().year,
              dateToShow.toUtc().month, dateToShow.toUtc().day, 0, 0)
          .add(const Duration(days: 1))
          .toLocal();

      upcomingLessons = defaultTimeTable.getUpcomingLessons(dateToShow);
      hwToShow = hws[dateToShow.toUtcOnlyDate()] ?? [];
      examToShow = exams[dateToShow.toUtcOnlyDate()] ?? [];
    } else {
      hwToShow = hws[dateToShow.toUtcOnlyDate()] ?? [];
      examToShow = exams[dateToShow.toUtcOnlyDate()] ?? [];
    }
    String whenText = showTommorrow ? 'tommorrow' : 'today';
    bool showMeals = settings.get(Setting.homeShowMeals);
    bool showBaka = settings.get(Setting.homeShowBaka);

    return ValueListenableBuilder(
      valueListenable: ScreenSize.isWideScreen,
      builder: (context, isWide, child) {
        return Scaffold(
          floatingActionButtonLocation:
              isWide ? FloatingActionButtonLocation.endDocked : null,
          floatingActionButton: kDebugMode
              ? FloatingActionButton.extended(
                  onPressed: () {
                    HomeworksDatabase().deleteAllFromDisk();
                    SubjectDatabase().deleteAllFromDisk();
                    ExamDatabase().deleteAllFromDisk();
                    firestoreService.logOut();
                    bakaService.logOut();
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
                                  onDelete: (hw) => deleteHw(context, ref, hw),
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
        );
      },
    );
  }
}
