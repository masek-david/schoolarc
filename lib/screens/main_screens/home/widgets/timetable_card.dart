import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/models/bakalari/timetable_lesson_model.dart';
import 'package:schoolarc/models/timetable/lesson_times_model.dart';
import 'package:schoolarc/models/timetable/timetable_model.dart';
import 'package:schoolarc/provider/bakalari/current_timetable_notifier.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/screens/timetable/widgets/timetable_tile.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/datetime_extension.dart';
import 'package:schoolarc/utils/extensions/string_extension.dart';
import 'package:schoolarc/utils/fonts.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/ago_text.dart';
import 'package:schoolarc/widgets/buttons/loading_icon_button.dart';
import 'package:schoolarc/widgets/text_actions.dart';
import 'package:schoolarc/widgets/tiles/error_tile.dart';

bool _isLessonsEmpty(List<(LessonTimes, TimeTableLesson)> lessons) {
  bool isEmpty = true;
  for (var value in lessons) {
    if (!value.$2.isEmpty) {
      isEmpty = false;
    }
  }
  return isEmpty;
}

class TimetableCard extends ConsumerWidget {
  const TimetableCard({
    super.key,
    required this.dateToShow,
    required this.whenText,
  });

  final DateTime dateToShow;
  final String whenText;

  void refresh(WidgetRef ref) {
    ref.read(currentTimetableProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showOnline = ref.watch(useBakaProvider);

    final current = ref.watch(currentTimetableProvider);
    final isLoading = current.isLoading;
    final error = current.error;
    final data = current.value;

    final defaultTimetable = timetableDb.timeTable;
    TimeTable timetable = defaultTimetable;
    if (showOnline && data != null && error == null) {
      timetable = data;
    }

    final upcomingLessons = timetable.getUpcomingLessons(dateToShow);
    bool areThereUpcomingLessons = !_isLessonsEmpty(upcomingLessons);

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: TextActions(
              text: areThereUpcomingLessons
                  ? '${context.loc.lessons} $whenText'
                  : context.loc.noLesson(whenText).capitalize(),
              greydOut: !areThereUpcomingLessons,
              actions: [
                LoadingIconButton(
                  icon: Icons.refresh,
                  onTap: () => refresh(ref),
                  isLoading: isLoading,
                ),
                IconButton(
                  onPressed: () {
                    ref.read(currentTimetableProvider.notifier).refreshIfOld();
                    Navigator.restorablePushNamed(
                        context, '/timetable-current');
                  },
                  icon: const Icon(
                    Icons.keyboard_arrow_right_rounded,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: AnimatedSize(
              duration: Durations.medium1,
              curve: Curves.decelerate,
              child: error != null && showOnline
                  ? ErrorTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      error: error,
                      text: context.loc.viewingOfflineTimetable,
                    )
                  : const SizedBox(
                      height: 0,
                      width: double.infinity,
                    ),
            ),
          ),
          if (areThereUpcomingLessons) const SizedBox(height: 8),
          if (areThereUpcomingLessons)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 4,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(width: 12),
                  ...List.generate(
                    upcomingLessons.length,
                    (index) {
                      final entry = upcomingLessons[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              entry.$1.startTime.format(context),
                              style: googleSansFlex(
                                width: 50,
                                color: getSubtleTextColor(context),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 100,
                            child: TimetableTile(
                              isHighlighted: entry.$1.isActive &&
                                  dateToShow.isSameDay(DateTime.now()),
                              lesson: entry.$2,
                              columnWidth:
                                  settings.get(Setting.timeTableTileWidth),
                              onTap: (lesson) =>
                                  lesson?.showLessonDialog(context, ref),
                              leftBottom: index == 0,
                              leftTop: index == 0,
                              rightBottom: index == upcomingLessons.length - 1,
                              rightTop: index == upcomingLessons.length - 1,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 12, bottom: 4),
            child: AgoText(stream: currentTimetableAgeProvider),
          ),
        ],
      ),
    );
  }
}
