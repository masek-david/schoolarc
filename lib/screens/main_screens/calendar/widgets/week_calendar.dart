import 'package:flutter/material.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/exams/exam_model.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/screens/main_screens/calendar/widgets/week_row.dart';
import 'package:schoolarc/screens/main_screens/calendar/widgets/weekdays_row.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/date_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/hold_drag_target.dart';

class WeekCalendar extends StatefulWidget {
  const WeekCalendar({
    super.key,
    required this.selectedDate,
    required this.setSelectedDate,
    required this.homeworks,
    required this.exams,
    required this.examOnEdit,
    required this.controller,
  });

  final Date selectedDate;
  final void Function(Date date) setSelectedDate;
  final Map<Date, List<Exam>> exams;
  final Map<Date, List<Homework>> homeworks;
  final void Function(Exam exam) examOnEdit;
  final PageController controller;

  @override
  State<WeekCalendar> createState() => _WeekCalendarState();
}

class _WeekCalendarState extends State<WeekCalendar> {
  /// focused day is always the date selected or if that date isnt in the current week, the middle day of the week
  late Date focusedDate = widget.selectedDate;

  Widget _buildScrollTarget(bool forward) {
    return HoldDragTarget(
      hoverStart: () => hintScroll(forward),
      heldAction: () => scroll(forward),
      builder: (context, candidateData, rejectedData) {
        return const SizedBox(width: 20);
      },
    );
  }

  void hintScroll(bool forward) {
    if (!mounted) return;
    widget.controller.animateTo(
      widget.controller.offset + (forward ? 20 : -20),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.decelerate,
    );
  }

  Future<void> scroll(bool forward) async {
    if (!mounted) return;
    if (forward) {
      await widget.controller.nextPage(
        duration: Durations.medium2,
        curve: Curves.decelerate,
      );
    } else {
      await widget.controller.previousPage(
        duration: Durations.medium2,
        curve: Curves.decelerate,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return Stack(
          children: [
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    final today = Date.today();
                    final page = today.weekSinceEpoch;

                    widget.controller.animateToPage(
                      page,
                      duration: Durations.medium2,
                      curve: Curves.decelerate,
                    );

                    widget.setSelectedDate(today);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      focusedDate.formatMonth(context),
                      style: context.txt.displaySmall,
                      textAlign: .left,
                    ),
                  ),
                ),
                WeekdaysRow(textColor: getSubtleTextColor(context)),
                SizedBox(
                  // the width is divided to 7 days, plus spacing for the exam tiles (i guessed it though)
                  height: width / 7 + 90,
                  child: PageView.builder(
                    onPageChanged: (value) {
                      final bool startOnMonday = settings.get(
                        Setting.weekStartsOnMonday,
                      );

                      if (Date.datesForWeek(
                        value,
                        startOnMonday: startOnMonday,
                      ).contains(widget.selectedDate)) {
                        setState(() {
                          focusedDate = widget.selectedDate;
                        });
                      } else {
                        setState(() {
                          focusedDate = Date.fromWeekSinceEpoch(
                            value,
                            weekStartsOnMonday: startOnMonday,
                          ).addDays(3);
                        });
                      }
                    },
                    controller: widget.controller,
                    itemBuilder: (context, weekSinceEpoch) {
                      final dates = Date.datesForWeek(
                        weekSinceEpoch,
                        startOnMonday: settings.get(Setting.weekStartsOnMonday),
                      );

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: WeekRow(
                          showMonthTitle: false,
                          dayBackground: context.col.surfaceContainerLow,
                          todayBackground: context.col.surface,
                          dates: dates,
                          selectedDate: widget.selectedDate,
                          onDateSelected: (date) {
                            setState(() {
                              focusedDate = date;
                            });
                            widget.setSelectedDate(date);
                          },
                          homeworks: widget.homeworks,
                          exams: widget.exams,
                          onExamTap: widget.examOnEdit,
                          onMonthTitleTap: () {},
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              left: 0,
              child: Row(
                mainAxisSize: .max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildScrollTarget(false),
                  _buildScrollTarget(true),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
