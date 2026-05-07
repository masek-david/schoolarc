import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/exams/exam_model.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/screens/main_screens/calendar/widgets/arrow_buttons_row.dart';
import 'package:schoolarc/screens/main_screens/calendar/widgets/week_row.dart';
import 'package:schoolarc/screens/main_screens/calendar/widgets/weekdays_row.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/date_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/hold_drag_target.dart';

class WeekCalendar extends ConsumerStatefulWidget {
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
  ConsumerState<WeekCalendar> createState() => _WeekCalendarState();
}

class _WeekCalendarState extends ConsumerState<WeekCalendar> {
  /// focused day is always the date selected or if that date isnt in the current week, the middle day of the week
  late Date focusedDate = widget.selectedDate;

  Widget _buildScrollTarget(bool forward) {
    return HoldDragTarget(
      hoverStart: () => hintScroll(forward),
      heldAction: () => scroll(forward),
      builder: (context, candidateData, rejectedData) {
        return const SizedBox(width: 25, height: double.infinity);
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
    vibrate.medium();
    if (forward) {
      await widget.controller.nextPage(
        duration: scrollDuration,
        curve: scrollCurve,
      );
    } else {
      await widget.controller.previousPage(
        duration: scrollDuration,
        curve: scrollCurve,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final showArrows = ref.watch(calendarShowArrowsProvider);
    final weekStartsOnMonday = ref.watch(weekStartsOnMondayProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return Stack(
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: showArrows ? .spaceBetween : .center,
                  children: [
                    if (showArrows)
                      ArrowButton(
                        left: true,
                        onPressed: () {
                          widget.controller.previousPage(
                            duration: scrollDuration,
                            curve: scrollCurve,
                          );
                        },
                      ),
                    GestureDetector(
                      onTap: () {
                        final today = Date.today();
                        final page = today.weekSinceEpoch;

                        widget.controller.animateToPage(
                          page,
                          duration: scrollDuration,
                          curve: scrollCurve,
                        );

                        widget.setSelectedDate(today);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          focusedDate.formatMonth(context),
                          style: context.txt.headlineMedium,
                          textAlign: .left,
                        ),
                      ),
                    ),
                    if (showArrows)
                      ArrowButton(
                        onPressed: () {
                          widget.controller.nextPage(
                            duration: scrollDuration,
                            curve: scrollCurve,
                          );
                        },
                      ),
                  ],
                ),
                WeekdaysRow(
                  textColor: getSubtleTextColor(context),
                  startOnMonday: weekStartsOnMonday,
                ),
                SizedBox(
                  // the width is divided to 7 days, plus spacing for the exam tiles (i guessed it though)
                  height: width / 7 + 90,
                  child: PageView.builder(
                    onPageChanged: (value) {
                      if (Date.datesForWeek(
                        value,
                        startOnMonday: weekStartsOnMonday,
                      ).contains(widget.selectedDate)) {
                        setState(() {
                          focusedDate = widget.selectedDate;
                        });
                      } else {
                        setState(() {
                          focusedDate = Date.fromWeekSinceEpoch(
                            value,
                            weekStartsOnMonday: weekStartsOnMonday,
                          ).addDays(3);
                        });
                      }
                    },
                    controller: widget.controller,
                    itemBuilder: (context, weekSinceEpoch) {
                      final dates = Date.datesForWeek(
                        weekSinceEpoch,
                        startOnMonday: weekStartsOnMonday,
                      );

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: WeekRow(
                          showMonthTitle: false,
                          dayBackground: context.col.surfaceContainerLow,
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
