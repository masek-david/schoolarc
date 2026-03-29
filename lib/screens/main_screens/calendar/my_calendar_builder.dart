import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/exams/exam_model.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/screens/main_screens/calendar/widgets/reschedule_drag_target.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/datetime_extension.dart';
import 'package:schoolarc/utils/fonts.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/web_request_focus.dart';
import 'package:table_calendar/table_calendar.dart';

const _animationDuration = Duration(milliseconds: 250);
const _dayMargin = EdgeInsets.symmetric(horizontal: 1.5);
const _borderRadius = 6.0;

RescheduleDragTarget _build({
  required BuildContext context,
  required DateTime day,
  bool selected = false,
  bool today = false,
  bool outside = false,
}) {
  today = DateTime.now().isSameDay(day);
  final col = context.col;
  var background = col.surfaceContainer;
  var foreground = col.onSurface;

  if (selected) {
    background = col.tertiaryContainer;
    foreground = col.onTertiaryContainer;
  }
  if (outside) {
    background = col.surfaceContainerLow;
    foreground = col.onSurface;
  }
  if (today) {
    foreground = col.onTertiaryContainer;
  }

  return RescheduleDragTarget(
    currentDate: Date.fromDateTime(day.toLocal()),
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
            top: selected
                ? const Radius.circular(36)
                : const Radius.circular(_borderRadius),
          ),
        ),
        margin: _dayMargin,
        alignment: .topCenter,
        // needed so it stays top aligned
        child: AspectRatio(
          aspectRatio: 1,
          child: AnimatedContainer(
            duration: _animationDuration,
            margin: const EdgeInsets.all(4),
            decoration: today
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? context.col.surfaceContainer
                        : context.col.tertiaryContainer,
                  )
                : null,
            alignment: Alignment.center,
            child: AnimatedDefaultTextStyle(
              duration: _animationDuration,
              style: googleSansFlex(
                size: 24,
                weight: selected ? 800 : 600,
                width: 121,
                roundness: 100,
                color: candidateData.isNotEmpty ? col.onPrimary : foreground,
              ),
              child: Text(day.day.toString()),
            ),
          ),
        ),
      );
    },
  );
}

CalendarBuilders<Object?> myCalendarBuilder({
  required void Function(Exam exam) examOnEdit,
  required void Function() onHeaderTapped,
}) {
  return CalendarBuilders(
    headerTitleBuilder: (context, day) {
      final formatter = day.year == DateTime.now().year
          ? DateFormat(
              'MMMM',
              context.locale.languageCode,
            )
          : DateFormat(
              'MMMM yyyy',
              context.locale.languageCode,
            );

      return GestureDetector(
        onTap: onHeaderTapped,
        child: Text(
          formatter.format(day),
          textAlign: .center,
          style: context.txt.headlineSmall,
        ),
      );
    },
    outsideBuilder: (context, day, focusedDay) {
      return _build(context: context, day: day, outside: true);
    },
    selectedBuilder: (context, day, focusedDay) {
      return _build(context: context, day: day, selected: true);
    },
    defaultBuilder: (context, day, focusedDay) {
      return _build(context: context, day: day);
    },
    todayBuilder: (context, day, focusedDay) {
      return _build(context: context, day: day, today: true);
    },
    markerBuilder: (context, day, events) {
      List<Homework> homeworks = [];
      List<Exam> exams = [];
      for (var event in events) {
        if (event is Homework) {
          homeworks.add(event);
        } else if (event is Exam) {
          exams.add(event);
        }
      }

      final maxHwMarkers = 5;
      final maxExamMarkers = 4;
      final tooManyHw = homeworks.length > maxHwMarkers;
      final tooManyExams = exams.length > maxExamMarkers;

      return Column(
        children: [
          // spacing under the date
          const SizedBox(height: 40),
          SizedBox(
            height: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                tooManyHw ? maxHwMarkers : homeworks.length,
                (index) {
                  if (tooManyHw && index == maxHwMarkers - 1) {
                    return const _Ellipsis();
                  }

                  Homework hw = homeworks[index];
                  Color markerColor = hw.priority.getColor(context);

                  return Container(
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: hw.isCompleted
                          ? markerColor.withAlpha(60)
                          : markerColor,
                      shape: BoxShape.circle,
                    ),
                    height: 8,
                    width: 8,
                  );
                },
              ),
            ),
          ),
          ...List.generate(
            tooManyExams ? maxExamMarkers : exams.length,
            (index) {
              if (tooManyExams && index == maxExamMarkers - 1) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: _Ellipsis(size: 13),
                );
              }

              Exam exam = exams[index];

              return WebRequestFocusBuilder(
                builder: (showKeyboard) {
                  return GestureDetector(
                    onTap: () {
                      showKeyboard();
                      examOnEdit(exam);
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
      );
    },
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
    margin: _dayMargin.copyWith(top: 2),
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
