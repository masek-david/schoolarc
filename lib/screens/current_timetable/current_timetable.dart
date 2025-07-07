import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/models/timetable/timetable_model.dart';
import 'package:school_manager/provider/baka_notifier.dart';
import 'package:school_manager/screens/current_timetable/loading_icon_button.dart';
import 'package:school_manager/screens/timetable/widgets/timetable_view.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';
import 'package:school_manager/widgets/error_tile.dart';
import 'package:school_manager/widgets/list_bottom_spacer.dart';
import 'package:school_manager/widgets/non_scrollable_refresh_indicator.dart';

class CurrentTimetableScreen extends ConsumerStatefulWidget {
  const CurrentTimetableScreen({super.key});

  @override
  ConsumerState<CurrentTimetableScreen> createState() =>
      _CurrentTimetableScreenState();
}

class _CurrentTimetableScreenState
    extends ConsumerState<CurrentTimetableScreen> {
  Future<TimeTable>? timetable;
  DateTime date = DateTime.now();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        setState(() {
          timetable = ref.read(bakaProvider.notifier).getCurrentTimetable(date);
        });
      },
    );
  }

  Future<void> refresh() async {
    setState(() {
      timetable = ref.read(bakaProvider.notifier).getCurrentTimetable(date);
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
            LoadingIconButton(
              icon: Icons.arrow_back,
              onTap: () async {
                date = date.subtract(const Duration(days: 7));
                return refresh();
              },
            ),
            LoadingIconButton(
              icon: Icons.home,
              onTap: () async {
                date = DateTime.now();
                return refresh();
              },
            ),
            LoadingIconButton(
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
