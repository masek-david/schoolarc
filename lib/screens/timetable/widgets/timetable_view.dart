import 'package:flutter/material.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/models/bakalari/timetable_lesson_model.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/timetable/lesson_times_model.dart';
import 'package:schoolarc/models/timetable/timetable_model.dart';
import 'package:schoolarc/screens/timetable/widgets/timetable_tile.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/date_extension.dart';
import 'package:schoolarc/utils/extensions/string_extension.dart';
import 'package:schoolarc/utils/fonts.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/dialogs/empty_message.dart';

class TimetableView extends StatelessWidget {
  const TimetableView({
    super.key,
    required this.timeTable,
    required this.showWholeWeek,
    required this.columnWidth,
    required this.onLessonTimesTapped,
    required this.onSubjectTapped,
    required this.textWhenEmpty,
  });

  final TimeTable? timeTable;
  final bool showWholeWeek;
  final double columnWidth;
  final String textWhenEmpty;
  final void Function(LessonTimes lessonTimes, int lessonIndex)?
  onLessonTimesTapped;
  final void Function(int weekday, int lessonIndex, TimeTableLesson lesson)?
  onSubjectTapped;

  static const dateColumnWidth = 40.0;

  @override
  Widget build(BuildContext context) {
    if (timeTable == null || timeTable!.lessonTimes.isEmpty) {
      return EmptyMessage(message: textWhenEmpty);
    }

    final table = timeTable!.table;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 8,
          right: 8,
          bottom: 36,
        ),
        child: Column(
          spacing: 4,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            showWholeWeek ? table.length + 1 : table.length - 2 + 1,
            (rowIndex) {
              if (rowIndex == 0) {
                return Row(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    timeTable!.lessonTimes.length + 1,
                    (columnIndex) {
                      if (columnIndex == 0) {
                        return SizedBox(
                          width: timeTable?.dates != null ? dateColumnWidth : 0,
                        );
                      }

                      int lessonIndex = columnIndex - 1;
                      final lessonTimes = timeTable!.lessonTimes[lessonIndex];

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: columnWidth,
                        child: InkWell(
                          onTap: onLessonTimesTapped == null
                              ? null
                              : () => onLessonTimesTapped!(
                                  lessonTimes,
                                  lessonIndex,
                                ),
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
                                style: googleSansFlex(
                                  width: 25,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
              int weekday = rowIndex - 1;

              if (!settings.get(Setting.weekStartsOnMonday)) {
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
                          width: dateColumnWidth,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                date
                                    .format('EEE', context.locale.languageCode)
                                    .capitalize(),
                                style: googleSansFlex(width: 110, weight: 600),
                                textAlign: .center,
                              ),
                              Text(
                                date.formatFromSettings(context),
                                style: googleSansFlex(width: 65),
                                textAlign: .center,
                              ),
                            ],
                          ),
                        );
                      }

                      int lessonIndex = columnIndex - 1;
                      final lesson = table[weekday][lessonIndex];

                      bool isHighlighted =
                          timeTable!.lessonTimes[lessonIndex].isActive &&
                          DateTime.now().weekday - 1 == weekday;

                      if (isHighlighted &&
                          date != null &&
                          !date.isSameDay(Date.today())) {
                        isHighlighted = false;
                      }

                      final isLeft = lessonIndex == 0;
                      final isRight = lessonIndex == table[0].length - 1;
                      final isTop = weekday == 0;
                      final isBottom = weekday == (showWholeWeek ? 6 : 4);

                      return TimetableTile(
                        leftBottom: isLeft && isBottom,
                        leftTop: isLeft && isTop,
                        rightBottom: isRight && isBottom,
                        rightTop: isRight && isTop,
                        isHighlighted: isHighlighted,
                        lesson: lesson,
                        columnWidth: columnWidth,
                        onTap: onSubjectTapped == null
                            ? null
                            : (_) => onSubjectTapped!(
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
        ),
      ),
    );
  }
}
