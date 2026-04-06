import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/exams/exam_model.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/screens/main_screens/calendar/widgets/week_row.dart';
import 'package:schoolarc/screens/main_screens/calendar/widgets/weekdays_row.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ScrollableCalendar extends ConsumerWidget {
  const ScrollableCalendar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.homeworks,
    required this.exams,
    required this.onExamTap,
    required this.controller,
    required this.onTitleTap,
  });

  final Date selectedDate;
  final Map<Date, List<Homework>> homeworks;
  final Map<Date, List<Exam>> exams;
  final void Function(Date selectedDate) onDateSelected;
  final void Function() onTitleTap;
  final void Function(Exam exam) onExamTap;
  final ItemScrollController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekStartsOnMonday = ref.watch(weekStartsOnMondayProvider);

    return Container(
      color: context.col.surfaceContainer,
      child: Column(
        children: [
          const WeekdaysRow(
            startOnMonday: false,
          ),
          const SizedBox(height: 4),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(12),
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(
                  context,
                ).copyWith(scrollbars: false),
                child: ScrollablePositionedList.builder(
                  itemScrollController: controller,
                  itemCount: 20000,
                  initialScrollIndex: selectedDate.weekSinceEpoch - 1,
                  itemBuilder: (context, weekSinceEpoch) {
                    final dates = Date.datesForWeek(
                      weekSinceEpoch,
                      startOnMonday: weekStartsOnMonday,
                    );

                    return WeekRow(
                      onMonthTitleTap: () {
                        final today = Date.today();
                        controller.scrollTo(
                          index: today.weekSinceEpoch - 1,
                          duration: const Duration(milliseconds: 350),
                        );
                        onDateSelected(today);
                      },
                      exams: exams,
                      homeworks: homeworks,
                      onDateSelected: onDateSelected,
                      dates: dates,
                      selectedDate: selectedDate,
                      onExamTap: onExamTap,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
