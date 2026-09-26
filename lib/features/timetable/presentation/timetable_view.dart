import 'package:flutter/material.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/features/timetable/domain/lesson_model.dart';
import 'package:schoolarc/features/timetable/domain/timetable_model.dart';
import 'package:schoolarc/features/timetable/presentation/timetable_tile.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/date_extension.dart';
import 'package:schoolarc/utils/extensions/string_extension.dart';
import 'package:schoolarc/utils/fonts.dart';
import 'package:schoolarc/utils/globals.dart';

class TimetableView extends StatelessWidget {
  const TimetableView({
    super.key,
    required this.timeTable,
    required this.showWholeWeek,
    required this.onPeriodTapped,
    required this.onLessonTapped,
    required this.contentWhenEmpty,
    this.onCreatePeriod,
  });

  final Timetable? timeTable;
  final bool showWholeWeek;
  final Widget contentWhenEmpty;
  final void Function()? onCreatePeriod;
  final void Function(int lessonIndex)? onPeriodTapped;
  final void Function(int weekday, int lessonIndex, Lesson lesson)?
  onLessonTapped;

  static const dateCellWidth = 40.0;
  static const cellWidth = 80.0;

  @override
  Widget build(BuildContext context) {
    if (timeTable == null || timeTable!.periods.isEmpty) {
      return contentWhenEmpty;
    }

    final bool startOnMonday = settings.get(Setting.weekStartsOnMonday);
    final table = timeTable!.table;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 8,
          right: 8,
          bottom: 8,
        ),
        child: Column(
          spacing: 4,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IntrinsicHeight(
              child: Row(
                spacing: 4,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: timeTable?.dates != null ? dateCellWidth : 0,
                  ),

                  ...List.generate(
                    timeTable!.periods.length,
                    (columnIndex) {
                      final lessonTimes = timeTable!.periods[columnIndex];

                      return SizedBox(
                        width: cellWidth,
                        child: InkWell(
                          borderRadius: .circular(4),
                          onTap: onPeriodTapped == null
                              ? null
                              : () => onPeriodTapped!(columnIndex),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                textAlign: TextAlign.center,
                                style: googleSansFlex(
                                  width: 151,
                                  size: 20,
                                ),
                                lessonTimes.name,
                              ),
                              Text(
                                textAlign: TextAlign.center,
                                lessonTimes.toStringFormatted(context),
                                style: googleSansFlex(width: 25),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  if (onCreatePeriod != null)
                    Material(
                      borderRadius: .circular(4),
                      color: context.col.surfaceContainerHigh,
                      clipBehavior: .antiAlias,
                      child: InkWell(
                        onTap: () => onCreatePeriod!.call(),
                        child: Container(
                          width: cellWidth,
                          alignment: .center,
                          child: const Icon(Icons.add_rounded),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            ...List.generate(
              showWholeWeek ? table.length : table.length - 2,
              (rowIndex) {
                int weekday = rowIndex;
                if (!startOnMonday) {
                  weekday--;
                  if (weekday == -1) {
                    weekday = 6;
                  }
                }

                return Expanded(
                  child: Row(
                    spacing: 4,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(
                      table[weekday].length + 1,
                      (columnIndex) {
                        final date = timeTable?.dates?[weekday];
                        if (columnIndex == 0) {
                          if (date == null) {
                            return const SizedBox();
                          }

                          return SizedBox(
                            width: dateCellWidth,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  date
                                      .format(
                                        'EEE',
                                        context.locale.languageCode,
                                      )
                                      .capitalize(),
                                  style: googleSansFlex(
                                    width: 110,
                                    weight: 600,
                                  ),
                                  textAlign: .center,
                                ),
                                Text(
                                  date.formatFromSettings(context),
                                  style: googleSansFlex(width: 45, size: 18),
                                  textAlign: .center,
                                ),
                              ],
                            ),
                          );
                        }

                        int lessonIndex = columnIndex - 1;
                        final lesson = table[weekday][lessonIndex];

                        bool isHighlighted =
                            timeTable!.periods[lessonIndex].isActive &&
                            DateTime.now().weekday - 1 == weekday;

                        if (isHighlighted &&
                            date != null &&
                            !date.isSameDay(Date.today())) {
                          isHighlighted = false;
                        }

                        final isLeft = lessonIndex == 0;
                        final isRight = lessonIndex == table[0].length - 1;
                        final isTop = rowIndex == 0;
                        final isBottom = rowIndex == (showWholeWeek ? 6 : 4);

                        return TimetableTile(
                          leftBottom: isLeft && isBottom,
                          leftTop: isLeft && isTop,
                          rightBottom: isRight && isBottom,
                          rightTop: isRight && isTop,
                          isHighlighted: isHighlighted,
                          lesson: lesson,
                          columnWidth: cellWidth,
                          onTap: onLessonTapped == null
                              ? null
                              : (_) => onLessonTapped!(
                                  weekday,
                                  lessonIndex,
                                  lesson,
                                ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
