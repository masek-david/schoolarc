import 'package:flutter/material.dart';
import 'package:school_manager/data/settings_database.dart';
import 'package:school_manager/screens/calendar/widgets/text_separator.dart';
import 'package:school_manager/screens/timetable/widgets/timetable_subject.dart';
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

  var tommorrow = DateTime.now().toUtc().add(const Duration(days: 1));
  late var tommorrowHw = homeworkService.getForDay(tommorrow);
  late var tommorrowExam = examService.getForDay(tommorrow);
  late var missedHw = homeworkService.getMissedHw();
  late var upcomingLessons = timetableDatabase.upcomingLessons;

  void updateView() {
    setState(() {
      hwNumberOfIncomplete = homeworkService.getNumberOfIncomplete();
      examNumberOfIncomplete = examService.getNumberOfIncomplete();
      tommorrow = DateTime.now().toUtc().add(const Duration(days: 1));
      tommorrowHw = homeworkService.getForDay(tommorrow);
      tommorrowExam = examService.getForDay(tommorrow);
      missedHw = homeworkService.getMissedHw();
      upcomingLessons = timetableDatabase.upcomingLessons;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool showUpcomingLessons = false;
    upcomingLessons.forEach(
      (key, value) {
        if (value != null) {
          showUpcomingLessons = true;
        }
      },
    );

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
      body: ListView(
        padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
        children: [
          if (upcomingLessons.isNotEmpty)
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
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TextSeparator(text: 'Upcoming lessons'),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                          children: upcomingLessons.entries.map<Widget>(
                        (entry) {
                          if (entry.value == null) {
                            return const SizedBox();
                          }
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: settings.get(Setting.timeTableTileWidth),
                                child: Text(
                                  entry.key.toStringFormatted(context),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(
                                height: 100,
                                child: TimetableSubject(
                                  isHighlighted: entry.key.isActive,
                                  subject: entry.value,
                                  columnWidth:
                                      settings.get(Setting.timeTableTileWidth),
                                  onTap: null,
                                  showName:
                                      settings.get(Setting.timeTableShowName),
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
                textFull: 'Exams tommorrow',
                showText: true,
                showDates: false,
                examList: tommorrowExam,
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
                textFull: 'Homeworks tommorrow',
                showText: true,
                showDates: false,
                hwList: tommorrowHw,
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
    );
  }
}
