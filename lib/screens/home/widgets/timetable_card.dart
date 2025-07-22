import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/models/bakalari/timetable_lesson_model.dart';
import 'package:school_manager/models/timetable/lesson_times_model.dart';
import 'package:school_manager/models/timetable/timetable_model.dart';
import 'package:school_manager/screens/calendar/widgets/text_separator.dart';
import 'package:school_manager/screens/current_timetable/current_timetable.dart';
import 'package:school_manager/screens/current_timetable/loading_icon_button.dart';
import 'package:school_manager/screens/timetable/widgets/timetable_tile.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';
import 'package:school_manager/utils/extensions/datetime_extension.dart';
import 'package:school_manager/utils/extensions/string_extension.dart';
import 'package:school_manager/widgets/error_tile.dart';

bool isLessonsEmpty(Map<LessonTimes, TimeTableLesson> lessons) {
  bool isEmpty = true;
  lessons.forEach(
    (lessonTimes, lesson) {
      if (!lesson.isEmpty) {
        isEmpty = false;
      }
    },
  );
  return isEmpty;
}

class TimetableCard extends StatelessWidget {
  const TimetableCard({
    super.key,
    required this.refresh,
    required this.defaultTimeTable,
    required this.bakaTimetable,
    required this.dateToShow,
    required this.whenText,
    required this.showOnline,
    required this.ref,
  });

  final void Function()? refresh;
  final TimeTable defaultTimeTable;
  final Future<TimeTable?>? bakaTimetable;
  final DateTime dateToShow;
  final String whenText;
  final bool showOnline;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: bakaTimetable,
      builder: (context, snapshot) {
        bool isLoading = false;
        Object? error;
        if (snapshot.connectionState == ConnectionState.waiting) {
          isLoading = true;
        } else if (snapshot.hasError) {
          error = snapshot.error;
        }

        TimeTable timetable = defaultTimeTable;
        if (snapshot.data != null && refresh != null && showOnline) {
          timetable = snapshot.data!;
        }

        final upcomingLessons = timetable.getUpcomingLessons(dateToShow);
        bool areThereUpcomingLessons = !isLessonsEmpty(upcomingLessons);

        return Card(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextSeparator(
                  text: '${context.loc.lessons} $whenText',
                  actions: [
                    if (refresh != null && showOnline)
                      AnimatedOpacity(
                        duration: Durations.medium1,
                        opacity: showOnline ? 1 : 0,
                        child: LoadingIconButton(
                          icon: Icons.refresh,
                          isLoading: isLoading,
                          onTap: () async {
                            return refresh!();
                          },
                        ),
                      ),
                    IconButton(
                      onPressed: () {
                        navigatorKey.currentState?.push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const CurrentTimetableScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.keyboard_arrow_right_rounded),
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: Durations.medium1,
                  curve: Curves.decelerate,
                  child: error != null && showOnline?
                     ErrorTile(
                      error: error,
                      text: context.loc.viewingOfflineTimetable,
                    ) : const SizedBox(height: 0, width: double.infinity,),
                  ),
                const SizedBox(height: 10),
                areThereUpcomingLessons
                    ? SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: upcomingLessons.entries.map<Widget>(
                              (entry) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      width: settings
                                          .get(Setting.timeTableTileWidth),
                                      child: Column(
                                        children: [
                                          Text(
                                            entry.key.name,
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            entry.key
                                                .toStringFormatted(context),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 100,
                                      child: TimetableTile(
                                        isHighlighted: entry.key.isActive &&
                                            dateToShow
                                                .isSameDay(DateTime.now()),
                                        lesson: entry.value,
                                        columnWidth: 80,
                                        onTap: (lesson) => lesson
                                            ?.showLessonDialog(context, ref),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ).toList()),
                      )
                    : Text(context.loc.noLesson(whenText).capitalize()),
              ],
            ),
          ),
        );
      },
    );
  }
}
