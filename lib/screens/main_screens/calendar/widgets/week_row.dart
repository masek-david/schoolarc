import 'package:flutter/material.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/exams/exam_model.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/screens/main_screens/calendar/widgets/day_calendar_tile.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/date_extension.dart';

const _daySpacing = 2.0;

class WeekRow extends StatelessWidget {
  const WeekRow({
    super.key,
    required this.dates,
    required this.selectedDate,
    required this.onDateSelected,
    required this.homeworks,
    required this.exams,
    required this.onExamTap,
    required this.onMonthTitleTap,
    this.dayBackground,
    this.showMonthTitle = true,
  });

  final Color? dayBackground;
  final bool showMonthTitle;

  final List<Date> dates;
  final Date selectedDate;
  final Map<Date, List<Homework>> homeworks;
  final Map<Date, List<Exam>> exams;
  final void Function() onMonthTitleTap;
  final void Function(Exam exam) onExamTap;
  final void Function(Date newSelectedDate) onDateSelected;

  @override
  Widget build(BuildContext context) {
    bool needsHeading = false;
    final firstMonth = dates.first.month;
    final lastMonth = dates.last.month;
    final today = Date.today();

    if ((firstMonth != lastMonth || dates.first.day == 1) && showMonthTitle) {
      needsHeading = true;
    }

    return Column(
      crossAxisAlignment: .start,
      children: [
        if (needsHeading)
          GestureDetector(
            onTap: onMonthTitleTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 8, 8),
              child: Text(
                dates.last.formatMonth(context),
                style: context.txt.displaySmall,
              ),
            ),
          ),
        Row(
          children: List.generate(
            dates.length,
            (index) {
              final date = dates[index];

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    index == 0 ? 0 : _daySpacing,
                    _daySpacing,
                    0,
                    0,
                  ),
                  child: DayTile(
                    backgroundColor: dayBackground,
                    onExamTap: onExamTap,
                    exams: exams[date] ?? [],
                    homeworks: homeworks[date] ?? [],
                    onTap: () => onDateSelected(date),
                    date: date,
                    isSelected: date == selectedDate,
                    isToday: date == today,
                    isOutside: !(date.month == lastMonth),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
