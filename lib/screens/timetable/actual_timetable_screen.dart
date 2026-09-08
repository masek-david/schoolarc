import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3e_widgets/m3e_widgets.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/m3e/expressive_loading/expressive_loading_indicator.dart';
import 'package:schoolarc/provider/bakalari/current_timetable_notifier.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/screens/timetable/widgets/timetable_view.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/ago_text.dart';
import 'package:schoolarc/widgets/dialogs/empty_message.dart';
import 'package:schoolarc/widgets/lists/non_scrollable_refresh_indicator.dart';
import 'package:schoolarc/widgets/tiles/error_tile.dart';

class ActualTimetableScreen extends ConsumerStatefulWidget {
  const ActualTimetableScreen({super.key});

  @override
  ConsumerState<ActualTimetableScreen> createState() =>
      _ActualTimetableScreenState();
}

class _ActualTimetableScreenState extends ConsumerState<ActualTimetableScreen> {
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16),
        child: M3EHorizontalFloatingToolbar(
          expanded: true,
          content: Row(
            children: [
              M3EIconButton(
                tooltip: context.loc.previousWeek,
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  setState(() {
                    week -= 1;
                  });
                },
              ),
              M3EIconButton(
                tooltip: context.loc.thisWeek,
                width: .wide,
                style: .filled,
                icon: const Icon(Icons.home_rounded),
                onPressed: () {
                  setState(() {
                    week = getCurrentTimetableWeekIndex();
                  });
                },
              ),
              M3EIconButton(
                tooltip: context.loc.nextWeek,
                icon: const Icon(Icons.arrow_forward_rounded),
                onPressed: () {
                  setState(() {
                    week += 1;
                  });
                },
              ),
            ],
          ),
        ),
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
                padding: const EdgeInsets.only(bottom: 80),
                child: SizedBox(
                  width: double.infinity,
                  child: TimetableView(
                    contentWhenEmpty: EmptyMessage(
                      message: context.loc.noTimetableMessage,
                    ),
                    timeTable: timetable,
                    showWholeWeek: settings.get(Setting.timeTableShowWholeWeek),
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
