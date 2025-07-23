import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:school_manager/database/exam_database.dart';
import 'package:school_manager/database/hw_database.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/database/subject_database.dart';
import 'package:school_manager/database/timetable_database.dart';
import 'package:school_manager/provider/exam_notifier.dart';
import 'package:school_manager/provider/hw_notifier.dart';
import 'package:school_manager/provider/subject_notifier.dart';
import 'package:school_manager/screens/baka_homeworks/baka_homeworks_screen.dart';
import 'package:school_manager/services/bakalari/baka_homeworks_service.dart';
import 'package:school_manager/services/bakalari/baka_service.dart';
import 'package:school_manager/services/logs_service.dart';
import 'package:school_manager/services/secure_storage.dart';
import 'package:school_manager/services/strava_service.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';
import 'package:uuid/uuid.dart';

var navigatorKey = GlobalKey<NavigatorState>();
final homeworksDb = HomeworksDatabase();
final examsDb = ExamDatabase();
final subjectsDb = SubjectDatabase();
final settings = SettingsDatabase();

final secureStorage = SecureStorage();
final timetableDb = TimeTableDatabase();
final bakaHomeworkService = BakaHomeworksService();
final stravaService = StravaService();
final bakaService = BakaService();
final logsService = LogsService();
final uuid = const Uuid();
late PackageInfo packageInfo;

Future<void> syncAllTasks(WidgetRef ref) async {
  await ref.read(subjectsProvider.notifier).syncAll();
  if (ref.context.mounted) {
    await Future.wait([
      ref.read(hwProvider.notifier).syncAll(),
      ref.read(examProvider.notifier).syncAll(),
    ]);
  }
  return;
}

void showMessage(
  BuildContext context,
  String message, {
  Duration? duration,
  bool isError = false,
  bool isContinuos = false,
  List<Widget>? actions,
}) {
  if (context.mounted) {
    if (isError) {
      duration ??= const Duration(seconds: 10);
    } else {
      duration ??= const Duration(seconds: 3);
    }
    if (isContinuos) {
      duration = const Duration(days: 100);
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        backgroundColor:
            isError ? Theme.of(context).colorScheme.errorContainer : null,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                message,
                maxLines: 5,
                style: TextStyle(
                  color: isError
                      ? Theme.of(context).colorScheme.onErrorContainer
                      : null,
                ),
              ),
            ),
            if (actions != null) ...actions,
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

Future<void> pushScreen(BuildContext context, Widget screen) {
  return Navigator.of(context).push(MaterialPageRoute(
    builder: (context) => screen,
  ));
}

void tryGettingNewHomeworks(BuildContext context) async {
  try {
    await bakaService.getHomeworks(
      onNewFound: (numberOfNew) {
        showMessage(
          context,
          context.loc.newHomeworksFound(numberOfNew),
          duration: const Duration(days: 100),
          actions: [
            FilledButton(
              onPressed: () {
                pushScreen(context, const BakaHomeworksScreen());
                ScaffoldMessenger.of(context).clearSnackBars();
              },
              child: Text(context.loc.view),
            ),
          ],
        );
      },
    );
  } on Object {
    // i dont mind this
  }
}
