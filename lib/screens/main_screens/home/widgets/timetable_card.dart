import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/models/timetable/lesson_times_model.dart';
import 'package:schoolarc/models/timetable/timetable_entry_model.dart';
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

bool _isLessonsEmpty(List<(LessonTimes, TimetableEntry)> lessons) {
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

  void refresh(WidgetRef ref, int week) {
    ref.read(actualTimetableDataProvider(week).notifier).refresh();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useBaka = ref.watch(useBakaProvider);

    final week = dateToShow.weekSinceEpoch;
    final current = ref.watch(actualTimetableProvider(week));
    final isLoading = current.isLoading;
    final error = current.error;
    final data = current.value;

    final defaultTimetable = timetableDb.timeTable;
    Timetable timetable = defaultTimetable;
    if (useBaka && data != null && error == null) {
      timetable = data;
    }

    final upcomingLessons = timetable.getUpcomingLessons(dateToShow);
    bool areThereUpcomingLessons = !_isLessonsEmpty(upcomingLessons);

    return CardWithTitle(
      childPadding: const .only(bottom: 8),
      text: areThereUpcomingLessons
          ? '${context.loc.lessons} $whenText'
          : context.loc.noLesson(whenText).capitalize(),
      error: useBaka ? error : null,
      greydOut: !areThereUpcomingLessons,
      errorText: context.loc.viewingOfflineTimetable,
      actions: [
        if (useBaka)
          LoadingIconButton(
            onPressed: () => refresh(ref, week),
            isLoading: isLoading,
          ),
        IconButton(
          onPressed: () {
            ref.read(actualTimetableDataProvider(week).notifier).refreshIfOld();
            Navigator.restorablePushNamed(
              context,
              '/timetable-actual',
            );
          },
          icon: const Icon(
            Icons.keyboard_arrow_right_rounded,
          ),
        ),
      ],
      child: !areThereUpcomingLessons
          ? null
          : SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: .horizontal,
                itemCount: upcomingLessons.length + 1,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemBuilder: (context, index) {
                  if (index == upcomingLessons.length) {
                    return Padding(
                      padding: const .only(top: 16),
                      child: AgoText(
                        stream: actualTimetableAgeProvider(week),
                      ),
                    );
                  }

                  final entry = upcomingLessons[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
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
                            onTap: (lesson) => lesson?.showLessonDialog(
                              context,
                              ref,
                              lessonTimes: entry.$1,
                            ),
                            leftBottom: index == 0,
                            leftTop: index == 0,
                            rightBottom: index == upcomingLessons.length - 1,
                            rightTop: index == upcomingLessons.length - 1,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
