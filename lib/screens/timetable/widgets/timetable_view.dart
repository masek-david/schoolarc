import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/l10n/my_localization.dart';
import 'package:school_manager/models/bakalari/timetable_lesson_model.dart';
import 'package:school_manager/models/timetable/lesson_times_model.dart';
import 'package:school_manager/models/timetable/timetable_model.dart';
import 'package:school_manager/screens/empty_message.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';
import 'package:school_manager/utils/extensions/datetime_extension.dart';
import 'package:school_manager/screens/timetable/widgets/timetable_tile.dart';
import 'package:school_manager/utils/extensions/string_extension.dart';

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
        emoji: '🍃',
        message: textWhenEmpty ?? context.loc.noTimetable,
      );
    }

    final table = timeTable!.table;

    return timeTable!.lessonTimes.isEmpty
        ? EmptyMessage(
            emoji: '🍃',
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
                                    Text(DateFormat(
                                            'EEE', getLocale().languageCode)
                                        .format(date)
                                        .capitalize()),
                                    Text(date.toLocal().formatWithoutYear()),
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
                                !date.isSameDay(DateTime.now())) {
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
