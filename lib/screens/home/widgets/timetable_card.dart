import 'package:flutter/material.dart';
import 'package:school_manager/data/bakalari/timetable_lesson_model.dart';
import 'package:school_manager/data/settings_database.dart';
import 'package:school_manager/data/table_data/lesson_times_model.dart';
import 'package:school_manager/data/table_data/table_dto_model.dart';
import 'package:school_manager/screens/calendar/widgets/text_separator.dart';
import 'package:school_manager/screens/current_timetable.dart/current_timetable.dart';
import 'package:school_manager/screens/current_timetable.dart/loading_icon_button.dart';
import 'package:school_manager/screens/timetable/widgets/timetable_tile.dart';
import 'package:school_manager/tasks_app.dart';

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
  });

  final void Function() refresh;
  final TimeTableDTO defaultTimeTable;
  final Future<TimeTableDTO?> bakaTimetable;
  final DateTime dateToShow;
  final String whenText;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: bakaTimetable,
      builder: (context, snapshot) {
        bool isLoading = false;
        String? error;
        if (snapshot.connectionState == ConnectionState.waiting) {
          isLoading = true;
        } else if (snapshot.hasError) {
          error = snapshot.error.toString();
        }

        TimeTableDTO timetable = defaultTimeTable;

        if (snapshot.data != null) {
          timetable = snapshot.data!;
        }

        final upcomingLessons = timetable.getUpcomingLessons(dateToShow);
        bool areThereUpcomingLessons = !isLessonsEmpty(upcomingLessons);

        return Card(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (error != null) Text(error),
                TextSeparator(
                  text: 'Lessons $whenText',
                  actions: [
                    LoadingIconButton(
                      icon: Icons.refresh,
                      isLoading: isLoading,
                      onTap: () async {
                        return refresh();
                      },
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
                                        isHighlighted: entry.key.isActive,
                                        lesson: entry.value,
                                        columnWidth: 80,
                                        onTap: (lesson) =>
                                            lesson?.showLessonDialog(context),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ).toList()),
                      )
                    : Text('No lessons $whenText')
              ],
            ),
          ),
        );
      },
    );
  }
}
