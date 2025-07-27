import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:schoolarc/database/exam_database.dart';
import 'package:schoolarc/database/hw_database.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/database/subject_database.dart';
import 'package:schoolarc/database/timetable_database.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/hw_notifier.dart';
import 'package:schoolarc/provider/subject_notifier.dart';
import 'package:schoolarc/services/bakalari/baka_homeworks_service.dart';
import 'package:schoolarc/services/bakalari/baka_service.dart';
import 'package:schoolarc/services/logs_service.dart';
import 'package:schoolarc/services/secure_storage.dart';
import 'package:schoolarc/services/strava_service.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
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
                Navigator.restorablePushNamed(context, '/bakalari-homeworks');
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
