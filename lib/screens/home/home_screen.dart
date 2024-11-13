import 'package:flutter/material.dart';
import 'package:school_manager/data/bakalari/timetable_lesson_model.dart';
import 'package:school_manager/data/settings_database.dart';
import 'package:school_manager/data/table_data/lesson_times_model.dart';
import 'package:school_manager/data/table_data/table_dto_model.dart';
import 'package:school_manager/screens/calendar/widgets/text_separator.dart';
import 'package:school_manager/screens/current_timetable.dart/current_timetable.dart';
import 'package:school_manager/screens/timetable/widgets/timetable_tile.dart';
import 'package:school_manager/widgets/exam_list.dart';
import 'package:school_manager/widgets/homework_list.dart';
import 'package:school_manager/tasks_app.dart';

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

  // for debugging
  // final now = DateTime(2024, 11, 13, 12, 51);
  final now = DateTime.now();
  late var dateToShow = now;
  late var hwToShow = homeworkService.getForDay(dateToShow);
  late var examToShow = examService.getForDay(dateToShow);
  late var missedHw = homeworkService.getMissedHw();
  late TimeTableDTO timeTable = timetableDatabase.timeTable;
  late var upcomingLessons = timeTable.getUpcomingLessons(dateToShow);

  void updateView() {
    setState(() {
      hwNumberOfIncomplete = homeworkService.getNumberOfIncomplete();
      examNumberOfIncomplete = examService.getNumberOfIncomplete();
      hwToShow = homeworkService.getForDay(dateToShow);
      examToShow = examService.getForDay(dateToShow);
      missedHw = homeworkService.getMissedHw();
    });
  }

  Future<void> setTimetable() async {
    if (!bakaService.isLoggedIn) {
      await tryLogin();
    }
    showMessage('Getting the timetable', isContinuos: true);

    var response = await bakaService.getCurrentTimetable(now);

    if (response.$1.isSuccess) {
      showMessage('Timetable loaded');
      if (response.$2 != null && mounted) {
        setState(() {
          timeTable = response.$2!;
        });
      }
    } else {
      tryLogin();
      showMessage(response.$1.error ?? '');
    }

    return;
  }

  Future<void> tryLogin() async {
    showMessage('Logging in', isContinuos: true);
    await bakaService.tryLogin().then(
      (value) {
        if (value.isSuccess) {
          showMessage('Logged in');
        } else {
          showMessage(value.error ?? '', isError: true);
        }
      },
    );
    return;
  }

  void showMessage(String message,
      {bool isError = false, bool isContinuos = false}) {
    if (mounted) {
      final duration = isError
          ? const Duration(seconds: 5)
          : isContinuos
              ? const Duration(days: 1)
              : const Duration(seconds: 1);

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: duration,
          backgroundColor:
              isError ? Theme.of(context).colorScheme.errorContainer : null,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                message,
                style: TextStyle(
                  color: isError
                      ? Theme.of(context).colorScheme.onErrorContainer
                      : null,
                ),
              ),
              if (isContinuos)
                CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
            ],
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(
      Duration.zero,
      () {
        setTimetable();
      },
    );
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
    dateToShow = now;
    var upcomingLessons = timeTable.getUpcomingLessons(dateToShow);

    bool showTommorrow = isLessonsEmpty(upcomingLessons);
    if (showTommorrow) {
      dateToShow = DateTime.utc(dateToShow.toUtc().year,
              dateToShow.toUtc().month, dateToShow.toUtc().day, 0, 0)
          .add(const Duration(days: 1))
          .toLocal();

      upcomingLessons = timeTable.getUpcomingLessons(dateToShow);
      hwToShow = homeworkService.getForDay(dateToShow);
      examToShow = examService.getForDay(dateToShow);
    }
    String whenText = showTommorrow ? 'tommorrow' : 'today';

    bool showUpcomingLessons = !isLessonsEmpty(upcomingLessons);

    return Scaffold(
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //   },
      //   label: const Text('Plan-it'),
      //   icon: const Icon(Icons.schedule),
      // ),
      appBar: AppBar(
        leading: DrawerButton(
          onPressed: widget.switchDrawer,
        ),
        title: const Text('Home'),
      ),
      body: RefreshIndicator(
        onRefresh: () => setTimetable(),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
          children: [
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
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
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
            if (showUpcomingLessons)
              Card(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextSeparator(
                        text: 'Lessons $whenText',
                        action: IconButton(
                          onPressed: () {
                            navigatorKey.currentState?.push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CurrentTimetableScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.keyboard_arrow_right_rounded),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: upcomingLessons.entries.map<Widget>(
                              (entry) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      width: settings
                                          .get(Setting.timeTableTileWidth),
                                      child: Column(
                                        children: [
                                          Text(
                                            entry.key.name,
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            entry.key
                                                .toStringFormatted(context),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 100,
                                      // settings.get(Setting.timeTableTileWidth) +
                                      // 8,
                                      child: TimetableTile(
                                        isHighlighted: entry.key.isActive &&
                                            !showTommorrow,
                                        lesson: entry.value,
                                        columnWidth: 80,
                                        // settings.get(Setting.timeTableTileWidth),
                                        onTap: (lesson) =>
                                            lesson?.showLessonDialog(context),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ).toList()),
                      ),
                    ],
                  ),
                ),
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
                    changeCompletion: changeCompletion,
                    deleteHw: (dbIndex) =>
                        deleteHw(context, dbIndex, () => updateView()).then(
                      (value) => updateView(),
                    ),
                    editHw: (dbIndex) => editHw(context, dbIndex).then(
                      (value) => updateView(),
                    ),
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
                  deleteExam: (dbIndex) =>
                      deleteExam(context, dbIndex, () => updateView()).then(
                    (value) => updateView(),
                  ),
                  editExam: (dbIndex) => editExam(context, dbIndex).then(
                    (value) => updateView(),
                  ),
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
                  changeCompletion: changeCompletion,
                  deleteHw: (dbIndex) =>
                      deleteHw(context, dbIndex, () => updateView()).then(
                    (value) => updateView(),
                  ),
                  editHw: (dbIndex) => editHw(context, dbIndex).then(
                    (value) => updateView(),
                  ),
                  updateListView: updateView,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
