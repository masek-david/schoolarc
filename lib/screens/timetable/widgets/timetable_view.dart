import 'package:flutter/material.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/l10n/my_localization.dart';
import 'package:schoolarc/models/bakalari/timetable_lesson_model.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/timetable/lesson_times_model.dart';
import 'package:schoolarc/models/timetable/timetable_model.dart';
import 'package:schoolarc/screens/timetable/widgets/timetable_tile.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/date_extension.dart';
import 'package:schoolarc/utils/extensions/string_extension.dart';
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
    this.textWhenEmpty,
  });

  final TimeTable? timeTable;
  final bool showWholeWeek;
  final double columnWidth;
  final String? textWhenEmpty;
  final void Function(LessonTimes lessonTimes, int lessonIndex)?
      onLessonTimesTapped;
  final void Function(int weekday, int lessonIndex, TimeTableLesson lesson)?
      onSubjectTapped;

  @override
  Widget build(BuildContext context) {
    if (timeTable == null) {
      return EmptyMessage(
        message: textWhenEmpty ?? context.loc.noTimetable,
      );
    }

    final table = timeTable!.table;

    return timeTable!.lessonTimes.isEmpty
        ? EmptyMessage(
            message: textWhenEmpty ?? context.loc.noTimetable,
          )
        : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 8,
                right: 8,
                bottom: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  showWholeWeek ? table.length + 1 : table.length - 2 + 1,
                  (rowIndex) {
                    if (rowIndex == 0) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          timeTable!.lessonTimes.length + 1,
                          (columnIndex) {
                            if (columnIndex == 0) {
                              return SizedBox(
                                  width: timeTable?.dates != null ? 60 : 0);
                            }

                            int lessonIndex = columnIndex - 1;
                            final lessonTimes =
                                timeTable!.lessonTimes[lessonIndex];

                            return Padding(
                              padding: const EdgeInsets.all(4),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                width: columnWidth,
                                child: InkWell(
                                  onTap: onLessonTimesTapped == null
                                      ? null
                                      : () => onLessonTimesTapped!(
                                          lessonTimes, lessonIndex),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        lessonTimes.name,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        textAlign: TextAlign.center,
                                        lessonTimes.toStringFormatted(context),
                                      ),
                                    ],
                                  ),
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
                                width: 60,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(date
                                        .format('EEE', getLocale().languageCode)
                                        .capitalize()),
                                    Text(date.formatFromSettings()),
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

                            return TimetableTile(
                              isHighlighted: isHighlighted,
                              lesson: lesson,
                              columnWidth: columnWidth,
                              onTap: onSubjectTapped == null
                                  ? null
                                  : (_) => onSubjectTapped!(
                                      weekday, lessonIndex, lesson),
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
