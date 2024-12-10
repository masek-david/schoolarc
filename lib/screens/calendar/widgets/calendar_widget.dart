import 'package:flutter/material.dart';
import 'package:school_manager/screens/calendar/my_calendar_builder.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.maxNumberOfCustomMarkers,
    required this.negativePageCount,
    required this.updateView,
    required this.calendarBackgroundColor,
    required this.jumpToPage,
    required this.getEventsForDay,
    required this.onHeaderTapped,
    required this.onFormatChanged,
    required this.onPageChanged,
  });

  final DateTime focusedDay;
  final DateTime selectedDay;
  final int maxNumberOfCustomMarkers;
  final int negativePageCount;
  final void Function() updateView;
  final Color calendarBackgroundColor;
  final Function(int page) jumpToPage;
  final Function(DateTime day) getEventsForDay;
  final void Function(DateTime)? onHeaderTapped;
  final void Function(CalendarFormat)? onFormatChanged;
  final void Function(DateTime)? onPageChanged;

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      // selected day je ten zvyraznenej a oznacenej, focused day je ten pro ktery se posune view v kalendari
      firstDay: DateTime(1),
      lastDay: DateTime(5000),
      focusedDay: focusedDay,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarFormat: CalendarFormat.week,
      availableCalendarFormats: const {CalendarFormat.week: 'Week'},
      rowHeight: 50 + maxNumberOfCustomMarkers * 25,
      calendarBuilders: myCalendarBuilder(updateView),
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
        return isSameDay(selectedDay, day);
      },
      onDaySelected: (selectedDayNew, focusedDayNew) {
        if (!isSameDay(selectedDayNew, selectedDay)) {
          // Call `setState()` when updating the selected day
          DateTime now = DateTime.now();
          // kdyz to neni utc neni to schopnej spravne porovnat
          DateTime nowOnlyDate = DateTime.utc(now.year, now.month, now.day);
          int dayDifferenceFromNow = selectedDayNew.difference(nowOnlyDate).inDays;
          int correctPageIndex = negativePageCount + dayDifferenceFromNow;

          jumpToPage(correctPageIndex);
        }
      },
      onHeaderTapped: onHeaderTapped,
      onFormatChanged: onFormatChanged,
      onPageChanged: onPageChanged,
    );
  }
}
