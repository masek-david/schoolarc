import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/models/timetable/timetable_model.dart';
import 'package:schoolarc/screens/current_timetable/loading_icon_button.dart';
import 'package:schoolarc/screens/timetable/widgets/timetable_view.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/error_tile.dart';
import 'package:schoolarc/widgets/list_bottom_spacer.dart';
import 'package:schoolarc/widgets/non_scrollable_refresh_indicator.dart';

class CurrentTimetableScreen extends ConsumerStatefulWidget {
  const CurrentTimetableScreen({super.key});

  @override
  ConsumerState<CurrentTimetableScreen> createState() =>
      _CurrentTimetableScreenState();
}

class _CurrentTimetableScreenState
    extends ConsumerState<CurrentTimetableScreen> {
  late Future<TimeTable> timetable = bakaService.getCurrentTimetable(date);
  DateTime date = DateTime.now();
  bool isLoading = true;

  Future<void> refresh() async {
    setState(() {
      timetable = bakaService.getCurrentTimetable(date);
    });

    try {
      await timetable;
    } catch (_) {}

    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.currentTimetable),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingIconButtonWithFuture(
              icon: Icons.arrow_back,
              onTap: () async {
                date = date.subtract(const Duration(days: 7));
                return refresh();
              },
            ),
            LoadingIconButtonWithFuture(
              icon: Icons.home,
              onTap: () async {
                date = DateTime.now();
                return refresh();
              },
            ),
            LoadingIconButtonWithFuture(
              icon: Icons.arrow_forward,
              onTap: () async {
                date = date.add(const Duration(days: 7));
                return refresh();
              },
            )
          ],
        ),
      ),
      body: NonScrollableRefreshIndicator(
        onRefresh: () async {
          await refresh();
        },
        child: FutureBuilder(
          future: timetable,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(child: ErrorTile(error: snapshot.error));
            } else if (!snapshot.hasData) {
              return Center(
                child: Text(context.loc.noTimetable),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: TimetableView(
                    textWhenEmpty: context.loc.noTimetable,
                    timeTable: snapshot.data,
                    showWholeWeek: settings.get(Setting.timeTableShowWholeWeek),
                    columnWidth: settings.get(Setting.timeTableTileWidth),
                    onLessonTimesTapped: null,
                    onSubjectTapped: (weekday, lessonIndex, lesson) {
                      lesson.showLessonDialog(context, ref);
                    },
                  ),
                ),
                const ListBottomSpacer(),
              ],
            );
          },
        ),
      ),
    );
  }
}
