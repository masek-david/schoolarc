import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/models/bakalari/timetable_lesson_model.dart';
import 'package:schoolarc/models/timetable/lesson_times_model.dart';
import 'package:schoolarc/models/timetable/timetable_model.dart';
import 'package:schoolarc/provider/bakalari/current_timetable_notifier.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/screens/main_screens/home/widgets/card_with_title.dart';
import 'package:schoolarc/screens/timetable/widgets/timetable_tile.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/datetime_extension.dart';
import 'package:schoolarc/utils/extensions/string_extension.dart';
import 'package:schoolarc/utils/fonts.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/ago_text.dart';
import 'package:schoolarc/widgets/buttons/loading_icon_button.dart';

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

    return CardWithTitle(
      childPadding: const .only(bottom: 8),
      text: areThereUpcomingLessons
          ? '${context.loc.lessons} $whenText'
          : context.loc.noLesson(whenText).capitalize(),
      error: error,
      greydOut: !areThereUpcomingLessons,
      errorText: context.loc.viewingOfflineTimetable,
      actions: [
        LoadingIconButton(
          onPressed: () => refresh(ref),
          isLoading: isLoading,
        ),
        IconButton(
          onPressed: () {
            ref.read(currentTimetableProvider.notifier).refreshIfOld();
            Navigator.restorablePushNamed(
              context,
              '/timetable-current',
            );
          },
          icon: const Icon(
            Icons.keyboard_arrow_right_rounded,
          ),
        ),
      ],
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            spacing: 4,
            children: [
              ...List.generate(
                upcomingLessons.length + 1,
                (index) {
                  if (index == upcomingLessons.length) {
                    return Padding(
                      padding: const .only(top: 16),
                      child: AgoText(stream: currentTimetableAgeProvider),
                    );
                  }

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
                          isHighlighted:
                              entry.$1.isActive &&
                              dateToShow.isSameDay(DateTime.now()),
                          lesson: entry.$2,
                          columnWidth: settings.get(
                            Setting.timeTableTileWidth,
                          ),
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
            ],
          ),
        ),
      ),
    );
  }
}
