import 'package:flutter/material.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/exams/exam_model.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/screens/main_screens/calendar/widgets/reschedule_drag_target.dart';
import 'package:schoolarc/utils/extensions/color_extension.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/fonts.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/web_request_focus.dart';

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

  static const _dotSize = 8.0;
  static const _dotSpacing = 2.0;
  static const _examTileHeight = 20.0;
  static const _maxExamMarkers = 4;
  static const _animationDuration = Duration(milliseconds: 300);
  static const _borderRadius = 8.0;

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

        final maxHwMarkers = (width / (_dotSize + _dotSpacing)).floor();
        final tooManyHw = homeworks.length > maxHwMarkers;
        final tooManyExams = exams.length > _maxExamMarkers;

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
                          height: _dotSize,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: _dotSpacing,
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
                                  height: _dotSize,
                                  width: _dotSize,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    ...List.generate(
                      _maxExamMarkers,
                      (index) {
                        if (tooManyExams && index == _maxExamMarkers - 1) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: _Ellipsis(size: 13),
                          );
                        }

                        final exam = exams.elementAtOrNull(index);

                        if (exam == null) {
                          return const SizedBox(height: _examTileHeight);
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
