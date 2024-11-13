import 'package:flutter/material.dart';
import 'package:school_manager/data/bakalari/baka_service.dart';
import 'package:school_manager/data/settings_database.dart';
import 'package:school_manager/data/table_data/table_dto_model.dart';
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
  bool isLoadingBack = false;
  bool isLoadingForward = false;
  bool isLoading = false;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(
      Duration.zero,
      () => setTimetable(),
    );
  }

  Future<bool> tryLogin() async {
    showMessage('Logging in', isContinuos: true);
    await bakaService.tryLogin().then(
      (value) {
        evaluateResponse(
          value,
          onSuccess: () {
            showMessage('Logged in');
            setState(() {
              isLoggedIn = true;
            });
          },
        );

        if (value.isSuccess) {
          return true;
        }
      },
    );

    return false;
  }

  Future<void> setTimetable() async {
    if (!bakaService.isLoggedIn) {
      await tryLogin();
    }

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
    if (response.isSuccess) {
      onSuccess();
      setState(() {
        isLoading = false;
        isLoadingBack = false;
        isLoadingForward = false;
      });
    } else {
      if (mounted) {
        tryLogin();
        showMessage(response.error ?? '', isError: true);
        setState(() {
          isLoading = false;
          isLoadingBack = false;
          isLoadingForward = false;
        });
      }
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
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                if (isLoadingBack) const CircularProgressIndicator(),
                IconButton(
                  onPressed: () {
                    date = date.subtract(const Duration(days: 7));
                    setTimetable();
                    setState(() {
                      isLoadingBack = true;
                    });
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
              ],
            ),
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                if (isLoading) const CircularProgressIndicator(),
                IconButton(
                  onPressed: () {
                    date = DateTime.now();
                    setTimetable();
                    setState(() {
                      isLoading = true;
                    });
                  },
                  icon: const Icon(Icons.home),
                ),
              ],
            ),
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                if (isLoadingForward) const CircularProgressIndicator(),
                IconButton(
                  onPressed: () {
                    date = date.add(const Duration(days: 7));
                    setTimetable();
                    setState(() {
                      isLoadingForward = true;
                    });
                  },
                  icon: const Icon(Icons.arrow_forward),
                ),
              ],
            ),
          ],
        ),
      ),
      body: NonScrollableRefreshIndicator(
        onRefresh: () async {
          await setTimetable();
        },
        child: Column(
          children: [
            Expanded(
              child: TimetableView(
                timeTable: timetable,
                showWholeWeek: settings.get(Setting.timeTableShowWholeWeek),
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
