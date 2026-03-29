import 'package:flutter/material.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/exams/exam_model.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/screens/main_screens/calendar/widgets/reschedule_drag_target.dart';
import 'package:schoolarc/utils/extensions/color_extension.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/date_extension.dart';
import 'package:schoolarc/utils/fonts.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/web_request_focus.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

// TODO scroll on hover

const _daySpacing = 2.0;
const dotSize = 8.0;
const dotSpacing = 2.0;
const examTileHeight = 20.0;
const maxExamMarkers = 4;
const _animationDuration = Duration(milliseconds: 300);
const _borderRadius = 8.0;

class ScrollableCalendar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      color: context.col.surfaceContainer,
      child: Column(
        children: [
          Row(
            children: List.generate(
              7,
              (index) => Expanded(
                child: Text(
                  textAlign: .center,
                  style: context.txt.labelLarge,
                  Date(
                    2026,
                    3,
                    2 + index,
                  ).format('EEE', context.locale.languageCode),
                ),
              ),
            ),
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
                      startOnMonday: true,
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
    this.todayBackground,
  });

  final Color? dayBackground;
  final Color? todayBackground;
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
                    todayColor: todayBackground,
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

class DayTile extends StatelessWidget {
  const DayTile({
    super.key,
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.isOutside,
    required this.onTap,
    required this.homeworks,
    required this.exams,
    required this.onExamTap,
    this.backgroundColor,
    this.todayColor,
  });

  final Date date;
  final bool isSelected;
  final bool isToday;
  final bool isOutside;
  final List<Homework> homeworks;
  final List<Exam> exams;
  final void Function(Exam exam) onExamTap;
  final void Function() onTap;

  final Color? backgroundColor;
  final Color? todayColor;

  @override
  Widget build(BuildContext context) {
    final col = context.col;
    var background = backgroundColor ?? col.surface;
    var foreground = col.onSurface;

    if (isOutside) {
      background = background.dynamicLighten(
        makeItLighter: false,
        amount: 0.01,
      );
    }
    if (isSelected) {
      background = col.tertiaryContainer;
      foreground = col.onTertiaryContainer;
    }
    if (isToday) {
      foreground = col.onTertiaryContainer;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final maxHwMarkers = (width / (dotSize + dotSpacing)).floor();
        final tooManyHw = homeworks.length > maxHwMarkers;
        final tooManyExams = exams.length > maxExamMarkers;

        return GestureDetector(
          onTap: onTap,
          child: RescheduleDragTarget(
            currentDate: date,
            builder: (context, candidateData, rejectedData) {
              if (candidateData.isNotEmpty) {
                vibrate.selection();
              }

              return AnimatedContainer(
                duration: _animationDuration,
                decoration: BoxDecoration(
                  color: candidateData.isNotEmpty ? col.primary : background,
                  borderRadius: BorderRadius.vertical(
                    bottom: const Radius.circular(_borderRadius),
                    top: isSelected
                        ? Radius.circular(width / 2)
                        : const Radius.circular(_borderRadius),
                  ),
                ),
                child: Column(
                  spacing: 2,
                  children: [
                    Stack(
                      alignment: .bottomCenter.add(const .xy(0, -0.1)),
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: AnimatedContainer(
                            duration: _animationDuration,
                            margin: const EdgeInsets.all(4),
                            decoration: isToday
                                ? BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        todayColor ??
                                        context.col.surfaceContainer,
                                  )
                                : null,
                            alignment: Alignment.center,
                            child: AnimatedDefaultTextStyle(
                              duration: _animationDuration,
                              style: googleSansFlex(
                                size: 24,
                                weight: isSelected ? 800 : 600,
                                width: 121,
                                roundness: 100,
                                color: candidateData.isNotEmpty
                                    ? col.onPrimary
                                    : foreground,
                              ),
                              child: Text(date.day.toString()),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: dotSize,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: dotSpacing,
                            children: List.generate(
                              tooManyHw ? maxHwMarkers : homeworks.length,
                              (index) {
                                if (tooManyHw && index == maxHwMarkers - 1) {
                                  return const _Ellipsis();
                                }

                                Homework hw = homeworks[index];
                                Color markerColor = hw.priority.getColor(
                                  context,
                                );

                                return Container(
                                  decoration: BoxDecoration(
                                    color: hw.isCompleted
                                        ? markerColor.withAlpha(60)
                                        : markerColor,
                                    shape: BoxShape.circle,
                                  ),
                                  height: dotSize,
                                  width: dotSize,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    ...List.generate(
                      maxExamMarkers,
                      (index) {
                        if (tooManyExams && index == maxExamMarkers - 1) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: _Ellipsis(size: 13),
                          );
                        }

                        final exam = exams.elementAtOrNull(index);

                        if (exam == null) {
                          return const SizedBox(height: examTileHeight);
                        }

                        return WebRequestFocusBuilder(
                          builder: (showKeyboard) {
                            return GestureDetector(
                              onTap: () {
                                showKeyboard();
                                onExamTap(exam);
                              },
                              child: LongPressDraggable(
                                data: exam,
                                onDragStarted: () => vibrate.medium(),
                                feedbackOffset: const Offset(0, -20),
                                dragAnchorStrategy: (draggable, context, position) {
                                  // show the tile 60 points on top of finger, and 50 is there to center it (the lenght is 100)
                                  return const Offset(50, 60);
                                },
                                childWhenDragging: Opacity(
                                  opacity: 0.3,
                                  child: _buildExamTile(exam, context),
                                ),
                                feedback: SizedBox(
                                  width: 100,
                                  child: _buildExamTile(exam, context),
                                ),
                                child: _buildExamTile(exam, context),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

Widget _buildExamTile(Exam exam, BuildContext context) {
  var backgroundCol = exam.priority.getContainerColor(context);
  var foregroundCol = exam.priority.getOnContainerColor(context);

  if (exam.isCompleted) {
    backgroundCol = backgroundCol.withAlpha(60);
    foregroundCol = foregroundCol.withAlpha(120);
  }

  final shortcut = exam.subject?.trimmedShortcut ?? '';

  return Container(
    width: double.maxFinite,
    padding: const EdgeInsets.all(2),
    decoration: BoxDecoration(
      color: backgroundCol,
      borderRadius: BorderRadius.circular(_borderRadius),
    ),
    child: Row(
      children: [
        if (shortcut != '')
          Text(
            '$shortcut ',
            maxLines: 1,
            softWrap: false,
            style: context.txt.labelMedium!.copyWith(
              fontWeight: const FontWeight(800),
              color: foregroundCol,
            ),
          ),
        Expanded(
          child: Text(
            exam.text,
            maxLines: 1,
            softWrap: false,
            style: context.txt.labelMedium!.copyWith(
              color: foregroundCol,
            ),
          ),
        ),
      ],
    ),
  );
}

class _Ellipsis extends StatelessWidget {
  // ignore: unused_element_parameter
  const _Ellipsis({super.key, this.size = 10});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .end,
      spacing: 0.5,
      children: List.generate(
        3,
        (index) => Container(
          decoration: BoxDecoration(
            color: context.col.onSurface,
            shape: .circle,
          ),
          width: (size - 1) / 3,
          height: (size - 1) / 3,
        ),
      ),
    );
  }
}
