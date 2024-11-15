import 'package:flutter/material.dart';
import 'package:school_manager/data/bakalari/baka_service.dart';
import 'package:school_manager/data/settings_database.dart';
import 'package:school_manager/data/table_data/table_dto_model.dart';
import 'package:school_manager/screens/current_timetable.dart/fab_button.dart';
import 'package:school_manager/screens/timetable/widgets/timetable_view.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/widgets/list_bottom_spacer.dart';
import 'package:school_manager/widgets/non_scrollable_refresh_indicator.dart';

class CurrentTimetableScreen extends StatefulWidget {
  const CurrentTimetableScreen({super.key});

  @override
  State<CurrentTimetableScreen> createState() => _CurrentTimetableScreenState();
}

class _CurrentTimetableScreenState extends State<CurrentTimetableScreen> {
  TimeTableDTO? timetable;
  DateTime date = DateTime.now();
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    Future.delayed(
      Duration.zero,
      () => setTimetable(),
    );
  }

  Future<void> setTimetable() async {
    var response = await bakaService.getCurrentTimetable(date);

    evaluateResponse(
      response.$1,
      onSuccess: () {
        // showMessage('Timetable loaded');
        if (mounted) {
          setState(() {
            timetable = response.$2;
          });
        }
      },
    );
    return;
  }

  void evaluateResponse(
    BakaResponse response, {
    required void Function() onSuccess,
  }) {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
    if (response.isSuccess) {
      onSuccess();
    } else {
      errorMessage = response.error;
      showMessage(response.error ?? '', isError: true);
    }
  }

  void showMessage(String message,
      {bool isError = false, bool isContinuos = false}) {
    if (mounted) {
      final duration = isError
          ? const Duration(seconds: 5)
          : isContinuos
              ? const Duration(days: 1)
              : const Duration(seconds: 1);

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: duration,
          backgroundColor:
              isError ? Theme.of(context).colorScheme.errorContainer : null,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                message,
                style: TextStyle(
                  color: isError
                      ? Theme.of(context).colorScheme.onErrorContainer
                      : null,
                ),
              ),
              if (isContinuos)
                CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current timetable'),
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
            FabButton(
              icon: Icons.arrow_back,
              onTap: () async {
                date = date.subtract(const Duration(days: 7));
                return setTimetable();
              },
            ),
            FabButton(
              icon: Icons.home,
              onTap: () async {
                date = DateTime.now();
                return setTimetable();
              },
            ),
            FabButton(
              icon: Icons.arrow_forward,
              onTap: () async {
                date = date.add(const Duration(days: 7));
                return setTimetable();
              },
            )
          ],
        ),
      ),
      body: NonScrollableRefreshIndicator(
        onRefresh: () async {
          await setTimetable();
        },
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Expanded(
                    child: TimetableView(
                      textWhenEmpty: errorMessage,
                      timeTable: timetable,
                      showWholeWeek:
                          settings.get(Setting.timeTableShowWholeWeek),
                      columnWidth: settings.get(Setting.timeTableTileWidth),
                      onLessonTimesTapped: null,
                      onSubjectTapped: (weekday, lessonIndex, lesson) {
                        lesson.showLessonDialog(context);
                      },
                    ),
                  ),
                  const ListBottomSpacer(),
                ],
              ),
      ),
    );
  }
}
