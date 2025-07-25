import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolarc/models/exams/exam_model.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/utils/extensions/color_extension.dart';
import 'package:schoolarc/widgets/reschedule_drag_target.dart';
import 'package:table_calendar/table_calendar.dart';

CalendarBuilders<Object?> myCalendarBuilder({
  required void Function(Exam exam) onEdit,
  required DateTime currentDate,
  required Color backgroundColor,
}) {
  final padding = const EdgeInsets.all(10);
  final margin = const EdgeInsets.only(top: 6);
  Duration animationDuration = const Duration(milliseconds: 200);

  return CalendarBuilders(
    outsideBuilder: (context, day, focusedDay) {
      return RescheduleDragTarget(
        currentDate: day,
        builder: (context, candidateData, rejectedData) {
          if (candidateData.isNotEmpty) {
            HapticFeedback.selectionClick();
          }

          return AnimatedContainer(
            padding: padding,
            margin: margin,
            duration: animationDuration,
            decoration: BoxDecoration(
              color: candidateData.isNotEmpty
                  ? Theme.of(context).colorScheme.primary
                  : backgroundColor,
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 40,
              child: Text(
                day.day.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.dynamicLighten(
                        makeItLighter:
                            Theme.of(context).brightness != Brightness.dark,
                        amount: 0.4,
                      ),
                ),
              ),
            ),
          );
        },
      );
    },
    selectedBuilder: (context, day, focusedDay) {
      return RescheduleDragTarget(
        currentDate: day,
        builder: (context, candidateData, rejectedData) {
          if (candidateData.isNotEmpty) {
            HapticFeedback.selectionClick();
          }

          return AnimatedContainer(
            padding: padding,
            margin: margin,
            duration: animationDuration,
            decoration: BoxDecoration(
              color: candidateData.isNotEmpty
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 40,
              child: Text(
                day.day.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          );
        },
      );
    },
    defaultBuilder: (context, day, focusedDay) {
      return RescheduleDragTarget(
        currentDate: day,
        builder: (context, candidateData, rejectedData) {
          if (candidateData.isNotEmpty) {
            HapticFeedback.selectionClick();
          }

          return AnimatedContainer(
            padding: padding,
            margin: margin,
            duration: animationDuration,
            decoration: BoxDecoration(
              color: candidateData.isNotEmpty
                  ? Theme.of(context).colorScheme.primary
                  : backgroundColor,
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 40,
              child: Text(
                textAlign: TextAlign.center,
                day.day.toString(),
              ),
            ),
          );
        },
      );
    },
    todayBuilder: (context, day, focusedDay) {
      Color color = Theme.of(context).colorScheme.secondaryContainer;
      return RescheduleDragTarget(
        currentDate: day,
        builder: (context, candidateData, rejectedData) {
          if (candidateData.isNotEmpty) {
            HapticFeedback.selectionClick();
          }

          return AnimatedContainer(
            padding: padding.subtract(const EdgeInsets.all(2)),
            margin: margin,
            duration: animationDuration,
            decoration: BoxDecoration(
              color: candidateData.isNotEmpty
                  ? Theme.of(context).colorScheme.primary
                  : null,
              border: Border.all(
                color: color,
                width: 2,
              ),
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 40,
              child: Text(
                textAlign: TextAlign.center,
                day.day.toString(),
              ),
            ),
          );
        },
      );
    },
    markerBuilder: (context, day, events) {
      final theme = Theme.of(context);
      List<Homework> homeworks = [];
      List<Exam> exams = [];
      for (var event in events) {
        if (event is Homework) {
          // if (!event.completion) {
          homeworks.add(event);
          // }
        } else if (event is Exam) {
          exams.add(event);
        }
      }

      return Wrap(
        children: [
          Column(
            children: [
              // spacing under the dates
              const SizedBox(height: 39),
              homeworks.isEmpty
                  ? const SizedBox(
                      height: 10.4,
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                          homeworks.length <= 5 ? homeworks.length : 5,
                          (index) {
                        Homework hw = homeworks[index];
                        Color markerColor = hw.priority.getColor(context);

                        return Container(
                          margin: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: hw.isCompleted
                                ? markerColor.withAlpha(40)
                                : markerColor,
                            shape: BoxShape.circle,
                          ),
                          height: 8,
                          width: 8,
                        );
                      }),
                    ),
              ...List.generate(
                exams.length <= 8 ? exams.length : 8,
                (index) {
                  Exam exam = exams[index];

                  return GestureDetector(
                    onTap: () => onEdit(exam),
                    child: LongPressDraggable(
                      data: exam,
                      onDragStarted: () => HapticFeedback.mediumImpact(),
                      feedbackOffset: const Offset(0, -80),
                      dragAnchorStrategy: (draggable, context, position) {
                        return const Offset(50, 60);
                      },
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: _buildExamTile(exam, context, theme),
                      ),
                      feedback: SizedBox(
                        width: 100,
                        child: _buildExamTile(exam, context, theme),
                      ),
                      child: _buildExamTile(exam, context, theme),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      );
    },
  );
}

Widget _buildExamTile(Exam exam, BuildContext context, ThemeData theme) {
  final isLight = theme.brightness == Brightness.light;
  final color =
      exam.priority.getContainerColor(context, subtle: exam.isCompleted);
  final shortcut = exam.subject?.trimmedShortcut ?? '';
  Color textColor = theme.colorScheme.onSurface;
  if (exam.isCompleted) {
    textColor = textColor.dynamicLighten(makeItLighter: isLight, amount: 0.2);
  }

  return Container(
    width: double.maxFinite,
    margin: const EdgeInsets.all(2),
    padding: const EdgeInsets.all(2),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      '$shortcut ${exam.text}',
      style: theme.textTheme.bodySmall!.copyWith(color: textColor),
      maxLines: 1,
      softWrap: false,
    ),
  );
}
