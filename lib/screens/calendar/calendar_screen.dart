import 'package:flutter/material.dart';
import 'package:school_manager/data/settings_database.dart';
import 'package:school_manager/screens/calendar/calendar_settings.dart';
import 'package:school_manager/screens/calendar/my_calendar_builder.dart';
import 'package:school_manager/widgets/exam_list.dart';
import 'package:school_manager/widgets/homework_list.dart';
import 'package:school_manager/data/exams_data/exam_dto_model.dart';
import 'package:school_manager/data/exams_data/exam_service.dart';
import 'package:school_manager/data/homeworks_data/hw_dto_model.dart';
import 'package:school_manager/data/homeworks_data/hw_service.dart';
import 'package:school_manager/widgets/add_bottom_sheet/add_bottom_sheet.dart';
import 'package:school_manager/widgets/expansion_title.dart';
import 'package:school_manager/widgets/list_bottom_spacer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:school_manager/extensions/datetime_extension.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({
    super.key,
    required this.switchDrawer,
    this.showTommorrow = false,
  });

  final void Function() switchDrawer;
  final bool showTommorrow;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _serviceHw = HomeworkService();
  final _serviceExam = ExamService();
  final _settings = SettingsDatabase();

  late Map<DateTime, List<HomeworkDTO>> hwByDate = _serviceHw.sortByDate();
  late List<HomeworkDTO> missedHwList = _serviceHw.getMissedHw();
  late Map<DateTime, List<ExamDTO>> examByDate = _serviceExam.sortByDate();

  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  late DateTime _selectedDay = _focusedDay;

  late Color calendarBackgroundColor;

  // how many pages you can scroll to negative
  static const  int negativePageCount = 1000000;
  late final showTommorrow = _settings.get(Setting.calendarInitialIsTommorrow) ||
        widget.showTommorrow;
  late final PageController _pageController = PageController(
    viewportFraction: 0.93,
    initialPage: negativePageCount + (showTommorrow ? 1 : 0),
  );
  // how many markers are used this week at most
  late int maxNumberOfCustomMarkers = getMaxNumberOfExamsPerDay();

  late bool showMissed = _settings.get(Setting.calendarShowMissed);

  @override
  void initState() {
    super.initState();

    if (showTommorrow) {
      _focusedDay =
          DateTime.now().toUtc().add(const Duration(days: 1)).toLocal();
      _selectedDay = _focusedDay;
    }
    updateView();
  }

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    calendarBackgroundColor = Theme.of(context).colorScheme.surface;
    // the color is needed or else the list will be visible under the calendar
  }

  void updateView() {
    if (mounted) {
      setState(() {
        hwByDate = _serviceHw.sortByDate();
        examByDate = _serviceExam.sortByDate();
        missedHwList = _serviceHw.getMissedHw();
        maxNumberOfCustomMarkers = getMaxNumberOfExamsPerDay();
      });
    }
  }

  void addTask(bool isHomework) {
    showAddBottomSheet(
      context,
      initialDate: _selectedDay,
      onSave: (
          {required date, required priority, subject, required text}) async {
        isHomework
            ? await _serviceHw.saveNewHW(
                date: date, priority: priority, subject: subject, text: text)
            : await _serviceExam.saveNewExam(
                date: date, priority: priority, subject: subject, text: text);
        updateView();
      },
    );
  }

  void editHw(int dbIndex) {
    HomeworkDTO hw = _serviceHw.getHomework(dbIndex);

    showAddBottomSheet(
      context,
      initialDate: hw.deadline,
      initialSubject: hw.subject,
      initialPriority: hw.priority,
      initialName: hw.text,
      onSave: ({required date, required priority, subject, required text}) {
        _serviceHw.saveEditedHW(
          date: date,
          priority: priority,
          subject: subject,
          text: text,
          completion: false,
          dbIndex: dbIndex,
        );
        updateView();
      },
    );
  }

  void editExam(int dbIndex) {
    ExamDTO exam = _serviceExam.getExam(dbIndex);

    showAddBottomSheet(
      context,
      initialDate: exam.deadline,
      initialSubject: exam.subject,
      initialPriority: exam.priority,
      initialName: exam.text,
      onSave: ({required date, required priority, subject, required text}) {
        _serviceExam.saveEditedExam(
          date: date,
          priority: priority,
          subject: subject,
          text: text,
          dbIndex: dbIndex,
        );
        updateView();
      },
    );
  }

  void changeCompletion(int dbIndex, bool value) {
    _serviceHw.changeCompletion(dbIndex, value);
  }

  void deleteHw(int dbIndex) {
    _serviceHw.deleteHw(dbIndex);
    updateView();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Homework deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            _serviceHw.revertLastlyDeletedHw();
            updateView();
          },
        ),
      ),
    );
  }

  void deleteExam(int dbIndex) {
    _serviceExam.deleteExam(dbIndex);
    updateView();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Exam deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            _serviceExam.revertLastlyDeletedExam();
            updateView();
          },
        ),
      ),
    );
  }

  /// used for gettin number of markers
  List<Object> getEventsForDay(DateTime day) {
    List<Object> listOfEvents = [
      ...hwByDate[DateTime.utc(day.year, day.month, day.day)] ?? [],
      ...examByDate[DateTime.utc(day.year, day.month, day.day)] ?? []
    ];
    return listOfEvents;
  }

  int getMaxNumberOfExamsPerDay() {
    var weekDays = _focusedDay.toUtc().allDaysInThisWeek();
    int examsCount = 0;

    for (DateTime date in weekDays) {
      int examsInDate =
          examByDate[DateTime.utc(date.year, date.month, date.day)]?.length ??
              0;

      if (examsInDate > examsCount) {
        examsCount = examsInDate;
      }
    }

    return examsCount <= 8 ? examsCount : 8;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: DrawerButton(
          onPressed: widget.switchDrawer,
        ),
        title: const Text('Calendar'),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => CalendarSettings(
                  changeShowMissed: (value) => setState(() {
                    showMissed = value;
                  }),
                ),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            tooltip: 'Add new exam for ${_selectedDay.formattedDate()}',
            heroTag: 'exam_btn',
            onPressed: () => addTask(false),
            icon: const Icon(Icons.add),
            label: const Text('Exam'),
          ),
          const SizedBox(
            height: 10,
          ),
          FloatingActionButton.extended(
            tooltip: 'Add new homework for ${_selectedDay.formattedDate()}',
            heroTag: 'homework_btn',
            onPressed: () => addTask(true),
            icon: const Icon(Icons.add),
            label: const Text('Homework'),
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            // selected day je ten zvyraznenej a oznacenej, focused day je ten pro ktery se posune view v kalendari
            firstDay: DateTime(1),
            lastDay: DateTime(5000),
            focusedDay: _focusedDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarFormat: _calendarFormat,
            availableCalendarFormats: const {CalendarFormat.week: 'Week'},
            rowHeight: 50 + maxNumberOfCustomMarkers * 25,
            calendarBuilders: myCalendarBuilder(editExam),
            headerStyle: HeaderStyle(
              decoration: BoxDecoration(color: calendarBackgroundColor),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              decoration: BoxDecoration(color: calendarBackgroundColor),
            ),
            calendarStyle: CalendarStyle(
              cellAlignment: Alignment.topCenter,
              markersAlignment: Alignment.topCenter,
              rowDecoration: BoxDecoration(color: calendarBackgroundColor),
            ),
            eventLoader: (day) => getEventsForDay(day),
            selectedDayPredicate: (day) {
              // Use `selectedDayPredicate` to determine which day is currently selected.
              // If this returns true, then `day` will be marked as selected.

              // Using `isSameDay` is recommended to disregard
              // the time-part of compared DateTime objects.
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                // Call `setState()` when updating the selected day
                DateTime now = DateTime.now();
                // kdyz to neni utc neni to schopnej spravne porovnat
                DateTime nowOnlyDate =
                    DateTime.utc(now.year, now.month, now.day);
                int dayDifferenceFromNow =
                    selectedDay.difference(nowOnlyDate).inDays;
                int correctPageIndex = negativePageCount + dayDifferenceFromNow;

                _pageController.jumpToPage(
                  correctPageIndex,
                );
              }
            },
            onHeaderTapped: (focusedDay) {
              setState(() {
                _focusedDay = DateTime.now();
              });
              _pageController.jumpToPage(negativePageCount);
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                // Call `setState()` when updating calendar format
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
                maxNumberOfCustomMarkers = getMaxNumberOfExamsPerDay();
              });
            },
          ),
          const SizedBox(height: 4),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (value) {
                setState(() {
                  _focusedDay = DateTime.now()
                      .toUtc()
                      .add(Duration(days: value - negativePageCount))
                      .toLocal();
                  _selectedDay = _focusedDay;
                });
              },
              itemBuilder: (context, pageIndex) {
                DateTime now = DateTime.now().toUtc();
                DateTime nowOnlyDate =
                    DateTime.utc(now.year, now.month, now.day);
                int daysToAdd = pageIndex - negativePageCount;
                DateTime date = nowOnlyDate.add(Duration(days: daysToAdd));

                List<HomeworkDTO> hwListForDay = hwByDate[date] ?? [];
                List<ExamDTO> examListForDay = examByDate[date] ?? [];

                final bool showMissed = missedHwList.isNotEmpty &&
                    !date.isBeforeToday() &&
                    this.showMissed;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ListView(
                    children: [
                      // Text(date.toString()),
                      // Text(pageIndex.toString()),
                      if (showMissed)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: ListTileTheme(
                            contentPadding:
                                const EdgeInsets.only(left: 4, right: 8),
                            child: ExpansionTile(
                              initiallyExpanded: false,
                              collapsedShape: const Border(),
                              shape: const Border(),
                              dense: true,
                              title: ExpansionTitle(
                                titleText: 'Missed Homeworks',
                                boldText: false,
                                titleTextColor:
                                    Theme.of(context).colorScheme.error,
                                numberOfItems: missedHwList.length,
                              ),
                              children: [
                                HomeworkList(
                                  hwList: missedHwList,
                                  changeCompletion: changeCompletion,
                                  deleteHw: deleteHw,
                                  editHw: editHw,
                                  updateListView: updateView,
                                )
                              ],
                            ),
                          ),
                        ),
                      ExamList(
                        showDates: false,
                        showText: true,
                        examList: examListForDay,
                        deleteExam: deleteExam,
                        editExam: editExam,
                      ),
                      HomeworkList(
                        showDates: false,
                        showText: true,
                        hwList: hwListForDay,
                        changeCompletion: changeCompletion,
                        deleteHw: deleteHw,
                        editHw: editHw,
                        updateListView: updateView,
                      ),
                      const ListBottomSpacer(),
                      const ListBottomSpacer(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
