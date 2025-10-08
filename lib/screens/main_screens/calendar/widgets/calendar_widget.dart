import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/l10n/my_localization.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/exams/exam_model.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/screens/main_screens/calendar/my_calendar_builder.dart';
import 'package:schoolarc/screens/main_screens/calendar/widgets/arrow_buttons_row.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/hold_drag_target.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends ConsumerStatefulWidget {
  const CalendarWidget({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.calendarFormat,
    required this.homeworks,
    required this.exams,
    required this.setSelectedDay,
    required this.setFocusedDay,
    required this.onEdit,
  });

  final DateTime focusedDay;
  final DateTime selectedDay;
  final CalendarFormat calendarFormat;
  final Map<Date, List<Exam>> exams;
  final Map<Date, List<Homework>> homeworks;
  final void Function(DateTime date) setFocusedDay;
  final void Function(DateTime date) setSelectedDay;
  final void Function(Exam exam) onEdit;

  @override
  ConsumerState<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends ConsumerState<CalendarWidget> {
  late final PageController pageController;
  bool isHoveringLeft = false;
  bool isHoveringRight = false;

  /// used for getting number of markers
  List<Object> getEventsForDay(Date day) {
    final currentExams = widget.exams[day] ?? [];

    List<Object> listOfEvents = [
      ...widget.homeworks[day] ?? [],
      ...currentExams
    ];
    return listOfEvents;
  }

  int getMaxNumberOfExamsPerDay() {
    List<Date> days = [];
    bool startOnMonday = settings.get(Setting.weekStartsOnMonday);

    if (widget.calendarFormat.name == 'month') {
      days = Date.fromDateTime(widget.focusedDay).allDaysInMonthCalendarView(startOnMonday);
    } else {
      days = Date.fromDateTime(widget.focusedDay).allDaysInThisWeek(startOnMonday);
    }

    int examsCount = 0;

    for (final date in days) {
      int examsInDate = widget.exams[date]?.length ?? 0;

      if (examsInDate > examsCount) {
        examsCount = examsInDate;
      }
    }

    return examsCount <= 8 ? examsCount : 8;
  }

  void previousPage() {
    if (!mounted) return;
    pageController.previousPage(
      duration: Durations.medium2,
      curve: Curves.easeInOut,
    );
  }

  void nextPage() {
    if (!mounted) return;
    pageController.nextPage(
      duration: Durations.medium2,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxNumberOfExamsPerDay = getMaxNumberOfExamsPerDay();
    final bool showArrows = ref.watch(calendarShowArrowsProvider) &&
        widget.calendarFormat.name == 'month';

    EdgeInsets padding = EdgeInsets.zero;
    if (widget.calendarFormat.name == 'month') {
      padding = EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          bottom: MediaQuery.of(context).padding.bottom);
    }

    return Container(
      color: context.col.surface,
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: padding,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  TableCalendar(
                    // selected day je ten zvyraznenej a oznacenej, focused day je ten pro ktery se posune view v kalendari
                    locale: getLocale().languageCode,
                    daysOfWeekHeight: 20,
                    firstDay: DateTime(0),
                    lastDay: DateTime(5000),
                    focusedDay: widget.focusedDay,
                    availableGestures: AvailableGestures.horizontalSwipe,
                    startingDayOfWeek: ref.watch(weekStartsOnMondayProvider)
                        ? StartingDayOfWeek.monday
                        : StartingDayOfWeek.sunday,
                    calendarFormat: widget.calendarFormat,
                    availableCalendarFormats: const {
                      CalendarFormat.week: 'Week',
                      CalendarFormat.month: 'Month',
                    },
                    rowHeight: 50 + maxNumberOfExamsPerDay * 25,
                    calendarBuilders: myCalendarBuilder(
                      onEdit: (exam) => widget.onEdit(exam),
                      currentDate: widget.focusedDay,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                    ),
                    headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        headerPadding: showArrows
                            ? const EdgeInsets.all(20)
                            : const EdgeInsets.symmetric(vertical: 8.0),
                        leftChevronVisible: !showArrows,
                        rightChevronVisible: !showArrows),
                    calendarStyle: const CalendarStyle(
                      cellAlignment: Alignment.topCenter,
                      markersAlignment: Alignment.topCenter,
                      tablePadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    eventLoader: (day) {
                      return getEventsForDay(Date.fromDateTime(day.toLocal()));
                    },
                    selectedDayPredicate: (day) {
                      // Use `selectedDayPredicate` to determine which day is currently selected.
                      // If this returns true, then `day` will be marked as selected.

                      // Using `isSameDay` is recommended to disregard
                      // the time-part of compared DateTime objects.
                      return isSameDay(widget.selectedDay, day);
                    },
                    onDaySelected: (selectedDayNew, focusedDayNew) {
                      widget.setSelectedDay(selectedDayNew);
                    },
                    onHeaderTapped: (focusedDay) {
                      widget.setSelectedDay(DateTime.now());
                    },
                    onPageChanged: widget.setFocusedDay,
                    onCalendarCreated: (pageController) {
                      this.pageController = pageController;
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildScrollTarget(maxNumberOfExamsPerDay, true),
                      _buildScrollTarget(maxNumberOfExamsPerDay, false),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (showArrows)
            Align(
              alignment: Alignment.center,
              child: ArrowButtonsRow(
                onPressedLeft: previousPage,
                onPressedRight: nextPage,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScrollTarget(int maxNumberOfExamsPerDay, bool isLeft) {
    return HoldDragTarget(
      heldAction: isLeft ? previousPage : nextPage,
      builder: (context, candidateData, rejectedData) {
        return SizedBox(
          height: widget.calendarFormat.name == 'week'
              ? (100 + 25 * maxNumberOfExamsPerDay).toDouble()
              : (320 + 25 * maxNumberOfExamsPerDay * 5).toDouble(),
          width: 20,
        );
      },
    );
  }
}
