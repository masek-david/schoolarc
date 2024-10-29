import 'package:flutter/material.dart';
import 'package:school_manager/data/exams_data/exam_dto_model.dart';
import 'package:school_manager/data/homeworks_data/hw_dto_model.dart';
import 'package:school_manager/data/priority_model.dart';
import 'package:table_calendar/table_calendar.dart';

CalendarBuilders<Object?> myCalendarBuilder(Function(int dbIndex) onTap) {
  EdgeInsetsGeometry padding = const EdgeInsets.all(10);
  EdgeInsetsGeometry margin = const EdgeInsets.all(6);
  Duration animationDuration = const Duration(milliseconds: 200);

  return CalendarBuilders(
    outsideBuilder: (context, day, focusedDay) {
      return AnimatedContainer(
        padding: padding,
        margin: margin,
        duration: animationDuration,
        decoration: const BoxDecoration(
          // color: Colors.red,
          shape: BoxShape.circle,
        ),
        child: SizedBox(
          width: 40,
          child: Text(
            day.day.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
            ),
          ),
        ),
      );
    },
    selectedBuilder: (context, day, focusedDay) {
      Color color = Theme.of(context).colorScheme.secondaryContainer;
      return AnimatedContainer(
        padding: padding,
        margin: margin,
        duration: animationDuration,
        decoration: BoxDecoration(
          color: color,
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
    defaultBuilder: (context, day, focusedDay) {
      return AnimatedContainer(
        padding: padding,
        margin: margin,
        duration: animationDuration,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
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
    todayBuilder: (context, day, focusedDay) {
      Color color = Theme.of(context).colorScheme.secondaryContainer;
      return AnimatedContainer(
        padding: padding.subtract(const EdgeInsets.all(2)),
        margin: margin,
        duration: animationDuration,
        decoration: BoxDecoration(
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
    markerBuilder: (context, day, events) {
      // Color markerColor = Theme.of(context).colorScheme.tertiary;
      List<HomeworkDTO> homeworks = [];
      List<ExamDTO> exams = [];
      for (var event in events) {
        if (event is HomeworkDTO) {
          // if (!event.completion) {
          homeworks.add(event);
          // }
        } else if (event is ExamDTO) {
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
                        HomeworkDTO hw = homeworks[index];
                        Color markerColor = Priority(hw.priority, context).color;

                        return Container(
                          margin: const EdgeInsets.all(1.2),
                          decoration: BoxDecoration(
                            color: hw.completion
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
                  ExamDTO exam = exams[index];
                  String shortcut = exam.subject?.trimmedShortcut ?? '';
                  Color color = Color.lerp(Priority(exam.priority, context).color,
                      Theme.of(context).colorScheme.surface, 0.3)!;

                  return GestureDetector(
                    onTap: () => onTap(exam.dbIndex),
                    child: Container(
                      width: double.maxFinite,
                      margin: const EdgeInsets.all(2),
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          color: color, borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        '$shortcut ${exam.text}',
                        style: const TextStyle(fontSize: 12),
                        maxLines: 1,
                        softWrap: false,
                      ),
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
