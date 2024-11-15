import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_manager/data/bakalari/timetable_lesson_model.dart';
import 'package:school_manager/data/table_data/lesson_times_model.dart';
import 'package:school_manager/data/table_data/table_dto_model.dart';
import 'package:school_manager/extensions/datetime_extension.dart';
import 'package:school_manager/screens/timetable/widgets/timetable_tile.dart';

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

  final TimeTableDTO? timeTable;
  final bool showWholeWeek;
  final double columnWidth;
  final String? textWhenEmpty;
  final void Function(LessonTimes lessonTimes, int lessonIndex)? onLessonTimesTapped;
  final void Function(int weekday, int lessonIndex, TimeTableLesson lesson)? onSubjectTapped;

  @override
  Widget build(BuildContext context) {
    if (timeTable == null) {
      return Center(
        child: Text(
          textWhenEmpty ?? 'No timetable found',
          textAlign: TextAlign.center,
        ),
      );
    }

    final table = timeTable!.table;

    return timeTable!.lessonTimes.isEmpty
        ? const Center(
            child: Text(
              'No timetable found.',
              textAlign: TextAlign.center,
            ),
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
                    return Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List.generate(
                          table[weekday].length + 1,
                          (columnIndex) {
                            if (columnIndex == 0) {
                              final date = timeTable?.dates?[weekday];
        
                              if (date == null) {
                                return const SizedBox();
                              }
        
                              return SizedBox(
                                width: 60,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(DateFormat('EEE').format(date)),
                                    Text(date.toLocal().formattedDate()),
                                  ],
                                ),
                              );
                            }
        
                            int lessonIndex = columnIndex - 1;
                            final lesson = table[weekday][lessonIndex];
        
                            bool isHighlighted =
                                timeTable!.lessonTimes[lessonIndex].isActive &&
                                    DateTime.now().weekday - 1 == weekday;
        
                            return TimetableTile(
                              isHighlighted: isHighlighted,
                              lesson: lesson,
                              columnWidth: columnWidth,
                              onTap: onSubjectTapped == null
                                  ? null
                                  : (_) =>
                                      onSubjectTapped!(weekday, lessonIndex, lesson),
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
