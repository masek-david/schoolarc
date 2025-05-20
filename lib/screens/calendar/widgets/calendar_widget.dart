import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_manager/models/exams/exam_model.dart';
import 'package:school_manager/models/homeworks/hw_model.dart';
import 'package:school_manager/screens/calendar/my_calendar_builder.dart';
import 'package:school_manager/screens/calendar/widgets/arrow_buttons_row.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/datetime_extension.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.negativePageCount,
    required this.calendarFormat,
    required this.jumpToPage,
    required this.onHeaderTapped,
    required this.onFormatChanged,
    required this.onPageChanged,
    required this.homeworks,
    required this.exams,
    required this.setFocusedDay,
    required this.onEdit,
  });

  final void Function(Exam exam) onEdit;
  final DateTime focusedDay;
  final DateTime selectedDay;
  final Map<DateTime, List<Homework>> homeworks;
  final Map<DateTime, List<Exam>> exams;
  final int negativePageCount;
  final CalendarFormat calendarFormat;
  final void Function(DateTime date) setFocusedDay;
  final Function(int page) jumpToPage;
  final void Function(DateTime)? onHeaderTapped;
  final void Function(CalendarFormat)? onFormatChanged;
  final void Function(DateTime)? onPageChanged;

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late final PageController pageController;
  bool isHoveringLeft = false;
  bool isHoveringRight = false;

  /// used for getting number of markers
  List<Object> getEventsForDay(DateTime day) {
    final currentExams =
        widget.exams[DateTime(day.year, day.month, day.day)] ?? [];

    List<Object> listOfEvents = [
      ...widget.homeworks[DateTime(day.year, day.month, day.day)] ?? [],
      ...currentExams
    ];
    return listOfEvents;
  }

  int getMaxNumberOfExamsPerDay() {
    List<DateTime> days = [];

    if (widget.calendarFormat.name == 'month') {
      days = widget.focusedDay.toUtc().allDaysInThisMonth();
    } else {
      days = widget.focusedDay.toUtc().allDaysInThisWeek();
    }

    int examsCount = 0;

    for (DateTime date in days) {
      int examsInDate =
          widget.exams[DateTime(date.year, date.month, date.day)]?.length ?? 0;

      if (examsInDate > examsCount) {
        examsCount = examsInDate;
      }
    }

    return examsCount <= 8 ? examsCount : 8;
  }

  void previousPage() {
    pageController.previousPage(
      duration: Durations.medium2,
      curve: Curves.easeInOut,
    );
  }

  void nextPage() {
    pageController.nextPage(
      duration: Durations.medium2,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxNumberOfExamsPerDay = getMaxNumberOfExamsPerDay();
    final bool showArrows = settings.get(Setting.calendarShowArrows) && widget.calendarFormat.name == 'month';

    return Stack(
      children: [
        SingleChildScrollView(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              TableCalendar(
                // selected day je ten zvyraznenej a oznacenej, focused day je ten pro ktery se posune view v kalendari
                firstDay: DateTime(0),
                lastDay: DateTime(5000),
                focusedDay: widget.focusedDay,
                availableGestures: AvailableGestures.horizontalSwipe,
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarFormat: widget.calendarFormat,
                availableCalendarFormats: const {
                  CalendarFormat.week: 'Week',
                  CalendarFormat.month: 'Month',
                },
                rowHeight: 50 + maxNumberOfExamsPerDay * 25,
                calendarBuilders: myCalendarBuilder(
                  onEdit: (exam) => widget.onEdit(exam),
                  currentDate: widget.focusedDay,
                  showOutside: widget.calendarFormat.name == 'week',
                ),
                headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    headerPadding: showArrows
                        ? const EdgeInsets.all(20)
                        : const EdgeInsets.symmetric(vertical: 8.0),
                    leftChevronVisible: !showArrows,
                    rightChevronVisible: !showArrows),
                calendarStyle: CalendarStyle(
                  cellAlignment: Alignment.topCenter,
                  markersAlignment: Alignment.topCenter,
                  tablePadding: EdgeInsets.symmetric(horizontal: 8),
                ),
                eventLoader: (day) {
                  return getEventsForDay(day);
                },
                selectedDayPredicate: (day) {
                  // Use `selectedDayPredicate` to determine which day is currently selected.
                  // If this returns true, then `day` will be marked as selected.

                  // Using `isSameDay` is recommended to disregard
                  // the time-part of compared DateTime objects.
                  return isSameDay(widget.selectedDay, day);
                },
                onDaySelected: (selectedDayNew, focusedDayNew) {
                  if (!selectedDayNew.isSameMonth(widget.focusedDay) &&
                      widget.calendarFormat.name == 'month') {
                    return;
                  }

                  if (!isSameDay(selectedDayNew, widget.selectedDay)) {
                    // Call `setState()` when updating the selected day
                    DateTime now = DateTime.now();
                    // kdyz to neni utc neni to schopnej spravne porovnat
                    DateTime nowOnlyDate =
                        DateTime.utc(now.year, now.month, now.day);
                    int dayDifferenceFromNow =
                        selectedDayNew.difference(nowOnlyDate).inDays;
                    int correctPageIndex =
                        widget.negativePageCount + dayDifferenceFromNow;

                    widget.jumpToPage(correctPageIndex);
                  }
                },
                onHeaderTapped: widget.onHeaderTapped,
                onFormatChanged: widget.onFormatChanged,
                onPageChanged: widget.onPageChanged,
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
        if (showArrows)
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(bottom: 56),
              child: ArrowButtonsRow(
                onPressedLeft: previousPage,
                onPressedRight: nextPage,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildScrollTarget(int maxNumberOfExamsPerDay, bool isLeft) {
    return DragTarget(
      onMove: (details) async {
        if (isLeft ? isHoveringLeft : isHoveringRight) {
          return;
        }
        if (isLeft) {
          isHoveringLeft = true;
        } else {
          isHoveringRight = true;
        }

        while (isLeft ? isHoveringLeft : isHoveringRight) {
          await Future.delayed(Duration(milliseconds: 1000));
          if (isLeft ? isHoveringLeft : isHoveringRight) {
            HapticFeedback.lightImpact();
            if (isLeft) {
              previousPage();
            } else {
              nextPage();
            }
          }
        }
      },
      onLeave: (data) {
        if (isLeft) {
          isHoveringLeft = false;
        } else {
          isHoveringRight = false;
        }
      },
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
