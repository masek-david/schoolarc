import 'package:flutter/material.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:school_manager/screens/calendar/widgets/calendar_widget.dart';
import 'package:school_manager/screens/calendar/widgets/pages_widget.dart';
import 'package:school_manager/screens/current_timetable/loading_icon_button.dart';
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
  late var hwByDate = homeworkService.sortByDate();
  late var missedHwList = homeworkService.getMissedHw();
  late var examByDate = examService.sortByDate();

  DateTime _focusedDay = DateTime.now();
  late DateTime _selectedDay = _focusedDay;

  // how many pages you can scroll to negative
  static const int negativePageCount = 1000000;
  late final showTommorrow =
      settings.get(Setting.calendarInitialIsTommorrow) || widget.showTommorrow;
  late final PageController _pageController = PageController(
    viewportFraction: 0.90,
    initialPage: negativePageCount + (showTommorrow ? 1 : 0),
  );

  late bool showMissed = settings.get(Setting.calendarShowMissed);
  final _resizeController = ResizableController();
  final initialSizes = (settings.get(
    Setting.calendarResizableContainerRatio,
  ) as List<double>)
      .map(
    (e) {
      return ResizableSize.ratio(e);
    },
  ).toList();

  @override
  void initState() {
    super.initState();

    if (showTommorrow) {
      _focusedDay =
          DateTime.now().toUtc().add(const Duration(days: 1)).toLocal();
      _selectedDay = _focusedDay;
    }

    _resizeController.addListener(
      () {
        settings.save(
          Setting.calendarResizableContainerRatio,
          _resizeController.ratios.toList(),
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  void updateView() {
    if (mounted) {
      setState(() {
        hwByDate = homeworkService.sortByDate();
        examByDate = examService.sortByDate();
        missedHwList = homeworkService.getMissedHw();
      });
    }
  }

  Widget buildCalendar(bool isWide) {
    return CalendarWidget(
      focusedDay: _focusedDay,
      selectedDay: _selectedDay,
      negativePageCount: negativePageCount,
      setFocusedDay: (date) {
        setState(() {
          _focusedDay = date;
        });
      },
      updateView: updateView,
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
      onFormatChanged: (format) {},
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
        if (settings.get(Setting.useFirebase))
          LoadingIconButton(
            icon: Icons.refresh,
            onTap: () async {
              try {
                return await firestoreService.syncAll().then(
                  (value) {
                    if (mounted) {
                      value.showSyncMessage(context);
                    }
                    updateView();
                  },
                );
              } on Object catch (e) {
                if (context.mounted) {
                  showMessage(context, e.toString(), isError: true);
                }
                return;
              }
            },
          ),
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
                  child: ResizableContainer(
                    controller: _resizeController,
                    direction: Axis.horizontal,
                    divider: ResizableDivider(
                      thickness: 4,
                      length: ResizableSize.pixels(60),
                      padding: 12,
                    ),
                    children: [
                      ResizableChild(
                        minSize: 300,
                        size: initialSizes[0],
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Scaffold(
                            appBar: buildAppBar(isWide),
                            body: buildCalendar(isWide),
                          ),
                        ),
                      ),
                      ResizableChild(
                        minSize: 300,
                        size: initialSizes[1],
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
