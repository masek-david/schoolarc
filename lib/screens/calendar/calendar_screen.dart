import 'package:flutter/material.dart';
import 'package:school_manager/screens/calendar/widgets/calendar_widget.dart';
import 'package:school_manager/screens/calendar/widgets/pages_widget.dart';
import 'package:school_manager/services/settings_database.dart';
import 'package:school_manager/screens/calendar/calendar_settings.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/screen_size.dart';
import 'package:school_manager/widgets/wide_screen_app_bar.dart';
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

  int maxMarkers = 0;

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

  Widget buildCalendar(bool isWide) {
    return CalendarWidget(
      focusedDay: _focusedDay,
      selectedDay: _selectedDay,
      negativePageCount: negativePageCount,
      updateView: updateView,
      calendarBackgroundColor: calendarBackgroundColor,
      calendarFormat: isWide ? CalendarFormat.month : CalendarFormat.week,
      homeworks: hwByDate,
      exams: examByDate,
      jumpToPage: (page) {
        _pageController.jumpToPage(page);
      },
      onHeaderTapped: (date) {
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
        });
      },
    );
  }

  Widget buildPages() {
    return PagesWidget(
      pageController: _pageController,
      onPageChanged: (page) {
        setState(() {
          _focusedDay = DateTime.now()
              .toUtc()
              .add(Duration(days: page - negativePageCount))
              .toLocal();
          _selectedDay = _focusedDay;
        });
      },
      negativePageCount: negativePageCount,
      hwByDate: hwByDate,
      examByDate: examByDate,
      missedHwList: missedHwList,
      showMissed: showMissed,
      updateView: updateView,
    );
  }

  PreferredSizeWidget buildAppBar(bool isWide) {
    return WideScreenAppBar(
      isWideScreen: isWide,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    /// how many markers are used this week at most
    // int maxNumberOfCustomMarkers = getMaxNumberOfExamsPerDay();

    return ValueListenableBuilder(
      valueListenable: ScreenSize.isWideScreen,
      builder: (context, isWide, child) {
        return Scaffold(
          appBar: isWide ? null : buildAppBar(isWide),
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
          body: isWide
              ? Container(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  width: double.infinity,
                  height: double.infinity,
                  child: Row(
                    children: [
                      Flexible(
                        // flex: 4,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Scaffold(
                            appBar: buildAppBar(isWide),
                            body: buildCalendar(isWide),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Flexible(
                        // flex: 5,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          child: buildPages(),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    buildCalendar(isWide),
                    const SizedBox(height: 4),
                    Expanded(child: buildPages()),
                  ],
                ),
        );
      },
    );
  }
}
