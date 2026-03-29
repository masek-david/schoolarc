import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/provider/bakalari/current_timetable_notifier.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/screens/timetable/widgets/floating_action_bar.dart';
import 'package:schoolarc/screens/timetable/widgets/timetable_view.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/ago_text.dart';
import 'package:schoolarc/widgets/dialogs/empty_message.dart';
import 'package:schoolarc/widgets/expressive_loading/expressive_loading_indicator.dart';
import 'package:schoolarc/widgets/lists/non_scrollable_refresh_indicator.dart';
import 'package:schoolarc/widgets/tiles/error_tile.dart';

class ActualTimetableScreen extends ConsumerStatefulWidget {
  const ActualTimetableScreen({super.key});

  @override
  ConsumerState<ActualTimetableScreen> createState() =>
      _ActualTimetableScreenState();
}

class _ActualTimetableScreenState
    extends ConsumerState<ActualTimetableScreen> {
  int week = getCurrentTimetableWeekIndex();

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(actualTimetableProvider(week));
    final error = provider.error;
    final timetable = provider.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.actualTimetable),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AgoText(stream: actualTimetableAgeProvider(week)),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionBar(
        actions: [
          FloatingActionBarAction(
            icon: Icons.arrow_back,
            onTap: () {
              setState(() {
                week -= 1;
              });
            },
          ),
          FloatingActionBarAction(
            icon: Icons.home,
            onTap: () {
              setState(() {
                week = getCurrentTimetableWeekIndex();
              });
            },
          ),
          FloatingActionBarAction(
            icon: Icons.arrow_forward,
            onTap: () {
              setState(() {
                week += 1;
              });
            },
          ),
        ],
      ),
      body: NonScrollableRefreshIndicator(
        onRefresh: () async {
          ref.read(actualTimetableDataProvider(week).notifier).refresh();
        },
        child: Builder(
          builder: (context) {
            if (provider.isLoading) {
              return Center(
                child: ExpressiveLoadingIndicator.big(
                  useHaptics: ref.read(themeExpressiveHapticsProvider),
                ),
              );
            }
            if (error != null) {
              return Center(
                child: ErrorTile(
                  error: error,
                  padding: const EdgeInsetsGeometry.all(16),
                ),
              );
            }
            if (timetable == null) {
              return EmptyMessage(message: context.loc.noTimetableMessage);
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: SizedBox(
                  width: double.infinity,
                  child: TimetableView(
                    contentWhenEmpty: EmptyMessage(
                      message: context.loc.noTimetableMessage,
                    ),
                    timeTable: timetable,
                    showWholeWeek: settings.get(Setting.timeTableShowWholeWeek),
                    columnWidth: settings.get(Setting.timeTableTileWidth),
                    onLessonTimesTapped: null,
                    onSubjectTapped: (weekday, lessonIndex, lesson) {
                      lesson.showLessonDialog(
                        context,
                        ref,
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
