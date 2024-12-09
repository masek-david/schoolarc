import 'package:flutter/material.dart';
import 'package:school_manager/services/settings_database.dart';
import 'package:school_manager/screens/calendar/calendar_settings.dart';
import 'package:school_manager/screens/calendar/my_calendar_builder.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/screen_size.dart';
import 'package:school_manager/widgets/exam_list.dart';
import 'package:school_manager/widgets/homework_list.dart';
import 'package:school_manager/models/exams/exam_dto_model.dart';
import 'package:school_manager/models/homeworks/hw_dto_model.dart';
import 'package:school_manager/widgets/expansion_title.dart';
import 'package:school_manager/widgets/list_bottom_spacer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:school_manager/utils/extensions/datetime_extension.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({
    super.key,
    this.showTommorrow = false,
  });

  final bool showTommorrow;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late var hwByDate = homeworkService.sortByDate(null);
  late var missedHwList = homeworkService.getMissedHw(null);
  late var examByDate = examService.sortByDate(null);

  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  late DateTime _selectedDay = _focusedDay;

  late Color calendarBackgroundColor;

  // how many pages you can scroll to negative
  static const int negativePageCount = 1000000;
  late final showTommorrow =
      settings.get(Setting.calendarInitialIsTommorrow) || widget.showTommorrow;
  late final PageController _pageController = PageController(
    viewportFraction: 0.93,
    initialPage: negativePageCount + (showTommorrow ? 1 : 0),
  );

  late bool showMissed = settings.get(Setting.calendarShowMissed);

  @override
  void initState() {
    super.initState();

    if (showTommorrow) {
      _focusedDay =
          DateTime.now().toUtc().add(const Duration(days: 1)).toLocal();
      _selectedDay = _focusedDay;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // the color is needed or else the list will be visible under the calendar
    calendarBackgroundColor = Theme.of(context).colorScheme.surface;
    updateView();
  }

  void updateView() {
    if (mounted) {
      setState(() {
        hwByDate = homeworkService.sortByDate(context);
        examByDate = examService.sortByDate(context);
        missedHwList = homeworkService.getMissedHw(context);
      });
    }
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
    /// how many markers are used this week at most
    int maxNumberOfCustomMarkers = getMaxNumberOfExamsPerDay();

    return ValueListenableBuilder(
      valueListenable: ScreenSize.isWideScreen,
      builder: (context, isWide, child) {
        return Scaffold(
          appBar: AppBar(
            leading: isWide
                ? null
                : const DrawerButton(
                    onPressed: switchDrawer,
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
                onPressed: () => addTask(context,
                        isHomework: false, initialDate: _selectedDay)
                    .then(
                  (value) => updateView(),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Exam'),
              ),
              const SizedBox(
                height: 10,
              ),
              FloatingActionButton.extended(
                tooltip: 'Add new homework for ${_selectedDay.formattedDate()}',
                heroTag: 'homework_btn',
                onPressed: () => addTask(context,
                        isHomework: true, initialDate: _selectedDay)
                    .then(
                  (value) => updateView(),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Homework'),
              ),
            ],
          ),
          // TODO this is ugly duplicate code
          body: isWide
              ? Row(
                  children: [
                    Flexible(
                      child: TableCalendar(
                        // selected day je ten zvyraznenej a oznacenej, focused day je ten pro ktery se posune view v kalendari
                        firstDay: DateTime(1),
                        lastDay: DateTime(5000),
                        focusedDay: _focusedDay,
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        calendarFormat: _calendarFormat,
                        availableCalendarFormats: const {
                          CalendarFormat.week: 'Week'
                        },
                        rowHeight: 50 + maxNumberOfCustomMarkers * 25,
                        calendarBuilders: myCalendarBuilder(updateView),
                        headerStyle: HeaderStyle(
                          decoration:
                              BoxDecoration(color: calendarBackgroundColor),
                        ),
                        daysOfWeekStyle: DaysOfWeekStyle(
                          decoration:
                              BoxDecoration(color: calendarBackgroundColor),
                        ),
                        calendarStyle: CalendarStyle(
                          cellAlignment: Alignment.topCenter,
                          markersAlignment: Alignment.topCenter,
                          rowDecoration:
                              BoxDecoration(color: calendarBackgroundColor),
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
                            int correctPageIndex =
                                negativePageCount + dayDifferenceFromNow;
                      
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
                            maxNumberOfCustomMarkers =
                                getMaxNumberOfExamsPerDay();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 4),
                    Flexible(
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
                          DateTime date =
                              nowOnlyDate.add(Duration(days: daysToAdd));

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
                                      contentPadding: const EdgeInsets.only(
                                          left: 4, right: 8),
                                      child: ExpansionTile(
                                        initiallyExpanded: true,
                                        collapsedShape: const Border(),
                                        shape: const Border(),
                                        dense: true,
                                        title: ExpansionTitle(
                                          titleText: 'Missed Homeworks',
                                          boldText: false,
                                          titleTextColor: Theme.of(context)
                                              .colorScheme
                                              .error,
                                          numberOfItems: missedHwList.length,
                                        ),
                                        children: [
                                          HomeworkList(
                                            hwList: missedHwList,
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
                                  updateView: updateView,
                                ),
                                HomeworkList(
                                  showDates: false,
                                  showText: true,
                                  hwList: hwListForDay,
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
                )
              : Column(
                  children: [
                    TableCalendar(
                      // selected day je ten zvyraznenej a oznacenej, focused day je ten pro ktery se posune view v kalendari
                      firstDay: DateTime(1),
                      lastDay: DateTime(5000),
                      focusedDay: _focusedDay,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      calendarFormat: _calendarFormat,
                      availableCalendarFormats: const {
                        CalendarFormat.week: 'Week'
                      },
                      rowHeight: 50 + maxNumberOfCustomMarkers * 25,
                      calendarBuilders: myCalendarBuilder(updateView),
                      headerStyle: HeaderStyle(
                        decoration:
                            BoxDecoration(color: calendarBackgroundColor),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        decoration:
                            BoxDecoration(color: calendarBackgroundColor),
                      ),
                      calendarStyle: CalendarStyle(
                        cellAlignment: Alignment.topCenter,
                        markersAlignment: Alignment.topCenter,
                        rowDecoration:
                            BoxDecoration(color: calendarBackgroundColor),
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
                          int correctPageIndex =
                              negativePageCount + dayDifferenceFromNow;

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
                          maxNumberOfCustomMarkers =
                              getMaxNumberOfExamsPerDay();
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
                          DateTime date =
                              nowOnlyDate.add(Duration(days: daysToAdd));

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
                                      contentPadding: const EdgeInsets.only(
                                          left: 4, right: 8),
                                      child: ExpansionTile(
                                        initiallyExpanded: true,
                                        collapsedShape: const Border(),
                                        shape: const Border(),
                                        dense: true,
                                        title: ExpansionTitle(
                                          titleText: 'Missed Homeworks',
                                          boldText: false,
                                          titleTextColor: Theme.of(context)
                                              .colorScheme
                                              .error,
                                          numberOfItems: missedHwList.length,
                                        ),
                                        children: [
                                          HomeworkList(
                                            hwList: missedHwList,
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
                                  updateView: updateView,
                                ),
                                HomeworkList(
                                  showDates: false,
                                  showText: true,
                                  hwList: hwListForDay,
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
      },
    );
  }
}
