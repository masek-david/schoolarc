import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:schoolarc/database/baka_homeworks_database.dart';
import 'package:schoolarc/database/exam_database.dart';
import 'package:schoolarc/database/hw_database.dart';
import 'package:schoolarc/database/logs_database.dart';
import 'package:schoolarc/database/secure_storage.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/database/subject_database.dart';
import 'package:schoolarc/database/timetable_database.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/hw_notifier.dart';
import 'package:schoolarc/provider/subject_notifier.dart';
import 'package:schoolarc/services/baka_service.dart';
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
final bakaHwDb = BakaHomeworksDatabase();
final stravaService = StravaService();
final bakaService = BakaService();
final logsService = LogsDatabase();
final uuid = const Uuid();
late PackageInfo packageInfo;

const noChange = Object();

/// returns true for web, windows, macos and linux
bool needsRefreshButton() {
  if (kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    return true;
  }
  return false;
}

Color getSubtleTextColor(BuildContext context) {
  if (Theme.brightnessOf(context) == Brightness.dark) {
    return context.col.surfaceBright;
  }
  return context.col.surfaceDim;
}

/// Used for fractional indexing
double getMiddleIndex(double first, double second) {
  return smaller(first, second) + (first - second).abs() / 2;
}

double smaller(double first, double second) {
  return first < second ? first : second;
}

Future<void> syncAllTasks(WidgetRef ref) async {
  await ref.read(subjectsProvider.notifier).syncAll();
  if (ref.context.mounted) {
    await Future.wait([
      ref.read(hwDataProvider.notifier).syncAll(),
      ref.read(examDataProvider.notifier).syncAll(),
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
