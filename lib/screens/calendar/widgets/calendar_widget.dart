import 'package:flutter/material.dart';
import 'package:school_manager/models/exams/exam_dto_model.dart';
import 'package:school_manager/models/homeworks/hw_dto_model.dart';
import 'package:school_manager/screens/calendar/my_calendar_builder.dart';
import 'package:school_manager/utils/extensions/datetime_extension.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.negativePageCount,
    required this.updateView,
    required this.calendarBackgroundColor,
    required this.calendarFormat,
    required this.jumpToPage,
    required this.onHeaderTapped,
    required this.onFormatChanged,
    required this.onPageChanged,
    required this.homeworks,
    required this.exams,
  });

  final DateTime focusedDay;
  final DateTime selectedDay;
  final Map<DateTime, List<HomeworkDTO>> homeworks;
  final Map<DateTime, List<ExamDTO>> exams;
  final int negativePageCount;
  final Color calendarBackgroundColor;
  final CalendarFormat calendarFormat;
  final void Function() updateView;
  final Function(int page) jumpToPage;
  final void Function(DateTime)? onHeaderTapped;
  final void Function(CalendarFormat)? onFormatChanged;
  final void Function(DateTime)? onPageChanged;

  /// used for getting number of markers
  List<Object> getEventsForDay(DateTime day) {
    final currentExams =
        exams[DateTime.utc(day.year, day.month, day.day)] ?? [];

    List<Object> listOfEvents = [
      ...homeworks[DateTime.utc(day.year, day.month, day.day)] ?? [],
      ...currentExams
    ];
    return listOfEvents;
  }

  int getMaxNumberOfExamsPerDay() {
    List<DateTime> days = [];

    if (calendarFormat.name == 'month') {
      days = focusedDay.toUtc().allDaysInThisMonth();
    } else {
      days = focusedDay.toUtc().allDaysInThisWeek();
    }

    int examsCount = 0;

    for (DateTime date in days) {
      int examsInDate =
          exams[DateTime.utc(date.year, date.month, date.day)]?.length ?? 0;

      if (examsInDate > examsCount) {
        examsCount = examsInDate;
      }
    }

    return examsCount <= 8 ? examsCount : 8;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: TableCalendar(
        // selected day je ten zvyraznenej a oznacenej, focused day je ten pro ktery se posune view v kalendari
        firstDay: DateTime(1),
        lastDay: DateTime(5000),
        focusedDay: focusedDay,
        availableGestures: AvailableGestures.horizontalSwipe,
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarFormat: calendarFormat,
        availableCalendarFormats: const {
          CalendarFormat.week: 'Week',
          CalendarFormat.month: 'Month',
        },
        rowHeight: 50 + getMaxNumberOfExamsPerDay() * 25,
        calendarBuilders: myCalendarBuilder(
          updateView: updateView,
          currentDate: focusedDay,
          showOutside: false
          // showOutside: calendarFormat.name == 'week',
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
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
        eventLoader: (day) {
          return getEventsForDay(day);
        },
        selectedDayPredicate: (day) {
          // Use `selectedDayPredicate` to determine which day is currently selected.
          // If this returns true, then `day` will be marked as selected.

          // Using `isSameDay` is recommended to disregard
          // the time-part of compared DateTime objects.
          return isSameDay(selectedDay, day);
        },
        onDaySelected: (selectedDayNew, focusedDayNew) {
          if (!isSameDay(selectedDayNew, selectedDay)) {
            // Call `setState()` when updating the selected day
            DateTime now = DateTime.now();
            // kdyz to neni utc neni to schopnej spravne porovnat
            DateTime nowOnlyDate = DateTime.utc(now.year, now.month, now.day);
            int dayDifferenceFromNow =
                selectedDayNew.difference(nowOnlyDate).inDays;
            int correctPageIndex = negativePageCount + dayDifferenceFromNow;

            jumpToPage(correctPageIndex);
          }
        },
        onHeaderTapped: onHeaderTapped,
        onFormatChanged: onFormatChanged,
        onPageChanged: onPageChanged,
      ),
    );
  }
}
