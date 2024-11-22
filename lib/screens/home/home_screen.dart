import 'package:flutter/material.dart';
import 'package:school_manager/data/bakalari/timetable_lesson_model.dart';
import 'package:school_manager/data/settings_database.dart';
import 'package:school_manager/data/stravacz/meal_model.dart';
import 'package:school_manager/data/stravacz/strava_service.dart';
import 'package:school_manager/data/table_data/lesson_times_model.dart';
import 'package:school_manager/data/table_data/table_dto_model.dart';
import 'package:school_manager/screens/home/widgets/meals_card.dart';
import 'package:school_manager/screens/home/widgets/timetable_card.dart';
import 'package:school_manager/widgets/exam_list.dart';
import 'package:school_manager/widgets/homework_list.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/widgets/list_bottom_spacer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.switchDrawer,
  });

  final void Function() switchDrawer;

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
  late Future<TimeTableDTO?> bakaTimetable;
  late Future<Map<DateTime, List<Meal>>> meals;

  void updateView() {
    setState(() {
      hwNumberOfIncomplete = homeworkService.getNumberOfIncomplete();
      examNumberOfIncomplete = examService.getNumberOfIncomplete();
      examToShow = examService.getForDay(dateToShow, context);
      hwToShow = homeworkService.getForDay(dateToShow, context);
      missedHw = homeworkService.getMissedHw(context);
    });
  }

  Future<void> refresh() async {
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
    await meals;
    return;
  }

  Future<void> refreshTimetable() async {
    setState(() {
      bakaTimetable = bakaService.getCurrentTimetable(dateToShow);
    });
    await bakaTimetable;
    return;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    updateView();
  }

  @override
  void initState() {
    super.initState();

    meals = stravaService.getMeals();
    bakaTimetable = bakaService.getCurrentTimetable(DateTime.now());
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

    bool showMeals =
        now.isBefore(DateTime(now.year, now.month, now.day, 14, 30));
    if (settings.get(Setting.showDebugInfo)) {
      showMeals = true;
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          StravaService().login();
        },
        label: const Text('Plan-it'),
        icon: const Icon(Icons.schedule),
      ),
      appBar: AppBar(
        leading: DrawerButton(
          onPressed: widget.switchDrawer,
        ),
        title: const Text('Home'),
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (showMeals) MealsCard(meals: meals, refresh: refreshMeals),
                Card(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Overview:',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hwNumberOfIncomplete.toString(),
                              style: TextStyle(
                                fontSize: 15,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              examNumberOfIncomplete.toString(),
                              style: TextStyle(
                                fontSize: 15,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'uncompleted homeworks',
                              style: TextStyle(fontSize: 15),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'upcoming exams',
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                TimetableCard(
                  refresh: refreshTimetable,
                  defaultTimeTable: defaultTimeTable,
                  bakaTimetable: bakaTimetable,
                  dateToShow: dateToShow,
                  whenText: whenText,
                ),
                if (missedHw.isNotEmpty)
                  Card(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
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
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
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
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
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
        ),
      ),
    );
  }
}
