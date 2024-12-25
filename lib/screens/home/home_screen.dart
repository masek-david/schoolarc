// ignore: unused_import
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:school_manager/models/bakalari/timetable_lesson_model.dart';
import 'package:school_manager/models/meal_model.dart';
import 'package:school_manager/models/timetable/lesson_times_model.dart';
import 'package:school_manager/models/timetable/table_dto_model.dart';
import 'package:school_manager/screens/home/home_settings.dart';
import 'package:school_manager/screens/home/widgets/meals_card.dart';
import 'package:school_manager/screens/home/widgets/overview.dart';
import 'package:school_manager/screens/home/widgets/timetable_card.dart';
import 'package:school_manager/services/firestore/firestore_service.dart';
import 'package:school_manager/utils/screen_size.dart';
import 'package:school_manager/widgets/exam_list.dart';
import 'package:school_manager/widgets/homework_list.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/widgets/list_bottom_spacer.dart';
import 'package:school_manager/widgets/wide_screen_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int hwNumberOfIncomplete = homeworkService.getNumberOfIncomplete();
  late int examNumberOfIncomplete = examService.getNumberOfIncomplete();

  late var dateToShow = DateTime.now();
  late var examToShow = examService.getForDay(dateToShow, null);
  late var hwToShow = homeworkService.getForDay(dateToShow, null);
  late var missedHw = homeworkService.getMissedHw(null);

  late TimeTableDTO defaultTimeTable = timetableDatabase.timeTable;
  late Future<TimeTableDTO?>? bakaTimetable;
  late Future<Map<DateTime, List<Meal>>>? meals;

  late final fire = FirestoreService();

  void updateView() {
    setState(() {
      hwNumberOfIncomplete = homeworkService.getNumberOfIncomplete();
      examNumberOfIncomplete = examService.getNumberOfIncomplete();
      examToShow = examService.getForDay(dateToShow, context);
      hwToShow = homeworkService.getForDay(dateToShow, context);
      missedHw = homeworkService.getMissedHw(context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    updateView();
  }

  @override
  void initState() {
    super.initState();

    bakaTimetable = bakaService.getCurrentTimetable(DateTime.now());
    meals = stravaService.getMeals();
  }

  Future<void> refresh() async {
    tryGettingNewHomeworks();

    await Future.wait([
      refreshMeals(),
      refreshTimetable(),
    ]);
    return;
  }

  Future<void> refreshMeals() async {
    setState(() {
      meals = stravaService.getMeals();
    });

    try {
      await meals;
    } catch (_) {}

    return;
  }

  Future<void> refreshTimetable() async {
    setState(() {
      bakaTimetable = bakaService.getCurrentTimetable(dateToShow);
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
    final now = DateTime.now();
    dateToShow = now;
    var upcomingLessons = defaultTimeTable.getUpcomingLessons(dateToShow);

    bool showTommorrow = isLessonsEmpty(upcomingLessons);
    if (showTommorrow) {
      dateToShow = DateTime.utc(dateToShow.toUtc().year,
              dateToShow.toUtc().month, dateToShow.toUtc().day, 0, 0)
          .add(const Duration(days: 1))
          .toLocal();

      upcomingLessons = defaultTimeTable.getUpcomingLessons(dateToShow);
      hwToShow = homeworkService.getForDay(dateToShow, context);
      examToShow = examService.getForDay(dateToShow, context);
    }
    String whenText = showTommorrow ? 'tommorrow' : 'today';

    return ValueListenableBuilder(
      valueListenable: ScreenSize.isWideScreen,
      builder: (context, isWide, child) {
        return Scaffold(
          // floatingActionButton: kDebugMode
          //     ? FloatingActionButton.extended(
          //         onPressed: () {
          //         },
          //         label: const Text('test'),
          //         icon: const Icon(Icons.bug_report),
          //       )
          //     : null,
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
                    hwNumberOfIncomplete: hwNumberOfIncomplete,
                    examNumberOfIncomplete: examNumberOfIncomplete,
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
                              meals: meals,
                              refresh: refreshMeals,
                            ),
                            TimetableCard(
                              refresh: refreshTimetable,
                              defaultTimeTable: defaultTimeTable,
                              bakaTimetable: bakaTimetable,
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
                            if (!isWide)
                              MealsCard(
                                meals: meals,
                                refresh: refreshMeals,
                              ),
                            if (!isWide)
                              TimetableCard(
                                refresh: refreshTimetable,
                                defaultTimeTable: defaultTimeTable,
                                bakaTimetable: bakaTimetable,
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
                                    textFull: 'Missed homeworks',
                                    showText: true,
                                    showDates: true,
                                    hwList: missedHw,
                                    updateListView: updateView,
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
                                  textFull: 'Exams $whenText',
                                  showText: true,
                                  showDates: false,
                                  examList: examToShow,
                                  updateView: updateView,
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
                                  textFull: 'Homeworks $whenText',
                                  showText: true,
                                  showDates: false,
                                  hwList: hwToShow,
                                  updateListView: updateView,
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
