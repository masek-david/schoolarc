import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/timetable/timetable_model.dart';
import 'package:schoolarc/provider/subject_notifier.dart';
import 'package:schoolarc/screens/timetable/widgets/floating_action_bar.dart';
import 'package:schoolarc/screens/timetable/widgets/timetable_view.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/dialogs/empty_message.dart';
import 'package:schoolarc/widgets/expressive_loading/expressive_loading_indicator.dart';
import 'package:schoolarc/widgets/lists/non_scrollable_refresh_indicator.dart';
import 'package:schoolarc/widgets/tiles/error_tile.dart';

class CurrentTimetableScreen extends ConsumerStatefulWidget {
  const CurrentTimetableScreen({super.key});

  @override
  ConsumerState<CurrentTimetableScreen> createState() =>
      _CurrentTimetableScreenState();
}

class _CurrentTimetableScreenState
    extends ConsumerState<CurrentTimetableScreen> {
  late Future<TimeTable> timetableFuture = bakaService.getCurrentTimetable(
    date,
  );
  TimeTable? timetable;
  Date date = Date.today();

  Future<void> refresh() async {
    setState(() {
      timetableFuture = bakaService.getCurrentTimetable(date);
    });

    try {
      await timetableFuture;
    } catch (_) {}

    return;
  }

  void reassignSubjects() {
    if (timetable == null) return;
    final subjects = ref.read(subjectsNonDeletedProvider);
    subjects.removeWhere((key, value) => value.bakaId == null);
    final subjectsBakaId = subjects.map(
      (key, value) => MapEntry(value.bakaId!, value),
    );

    for (var dayIndex = 0; dayIndex < timetable!.table.length; dayIndex++) {
      for (
        var lessonIndex = 0;
        lessonIndex < timetable!.table[dayIndex].length;
        lessonIndex++
      ) {
        final lesson = timetable!.table[dayIndex][lessonIndex];
        if (lesson.subject?.id == '') {
          timetable!.table[dayIndex][lessonIndex] = lesson.copyWith(
            subject: subjectsBakaId[lesson.subject?.bakaId],
          );
        }
      }
    }
    setState(() {
      timetable = timetable;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.loc.currentTimetable)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionBar(
        actions: [
          FloatingActionBarAction(
            icon: Icons.arrow_back,
            onTap: () {
              date = date.subtractDays(7);
              refresh();
            },
          ),
          FloatingActionBarAction(
            icon: Icons.home,
            onTap: () {
              date = Date.today();
              refresh();
            },
          ),
          FloatingActionBarAction(
            icon: Icons.arrow_forward,
            onTap: () {
              date = date.addDays(7);
              refresh();
            },
          ),
        ],
      ),
      body: NonScrollableRefreshIndicator(
        onRefresh: () async {
          await refresh();
        },
        child: FutureBuilder(
          future: timetableFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              timetable = null;
              return const Center(
                child: ExpressiveLoadingIndicator(size: 72),
              );
            } else if (snapshot.hasError) {
              timetable = null;
              return Center(
                child: ErrorTile(
                  error: snapshot.error,
                  padding: const EdgeInsetsGeometry.all(16),
                ),
              );
            } else if (!snapshot.hasData) {
              timetable = null;
              return EmptyMessage(message: context.loc.noTimetable);
            }

            timetable ??= snapshot.data!;

            return Column(
              children: [
                Expanded(
                  child: TimetableView(
                    textWhenEmpty: context.loc.noTimetable,
                    timeTable: timetable,
                    showWholeWeek: settings.get(Setting.timeTableShowWholeWeek),
                    columnWidth: settings.get(Setting.timeTableTileWidth),
                    onLessonTimesTapped: null,
                    onSubjectTapped: (weekday, lessonIndex, lesson) {
                      lesson.showLessonDialog(
                        context,
                        ref,
                        onSubjectAdded: reassignSubjects,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 60),
              ],
            );
          },
        ),
      ),
    );
  }
}
