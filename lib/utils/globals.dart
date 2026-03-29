import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:schoolarc/database/baka_homeworks_database.dart';
import 'package:schoolarc/database/exam_database.dart';
import 'package:schoolarc/database/hw_database.dart';
import 'package:schoolarc/database/logs_database.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/database/subject_database.dart';
import 'package:schoolarc/database/timetable_database.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/hw_notifier.dart';
import 'package:schoolarc/provider/subject_notifier.dart';
import 'package:schoolarc/services/baka_service.dart';
import 'package:schoolarc/services/firebase/firebase_service.dart';
import 'package:schoolarc/services/strava_service.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/datetime_extension.dart';
import 'package:schoolarc/utils/vibrate.dart';
import 'package:schoolarc/widgets/expressive_loading/expressive_loading_indicator.dart';
import 'package:schoolarc/widgets/tiles/error_tile.dart';
import 'package:uuid/uuid.dart';

var navigatorKey = GlobalKey<NavigatorState>();
final homeworksDb = HomeworksDatabase();
final examsDb = ExamDatabase();
final subjectsDb = SubjectDatabase();
final settings = SettingsDatabase();
final timetableDb = TimeTableDatabase();
final bakaHwDb = BakaHomeworksDatabase();
final stravaService = StravaService();
final bakaService = BakaService();
final fireService = FirebaseService();
final logsService = LogsDatabase();
final uuid = const Uuid();
late final Vibrate vibrate;
late final PackageInfo packageInfo;
final timeoutDuration = const Duration(seconds: 10);
const millisecondsInDay = 86400000;

const bakaPollingRate = Duration(minutes: 60);
const stravaPollingRate = Duration(minutes: 240);

const noChange = Object();

/// Returns the week number of the week that should be shown in the current timetable - for Saturday and Sunday show next week
int getCurrentTimetableWeekIndex() {
  final now = DateTime.now();
  var week = now.weekSinceEpoch;
  if (now.weekday >= 6) {
    week += 1;
  }
  return week;
}

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

void showErrorMessage(BuildContext context, Object error, {String? message}) {
  if (!context.mounted) return;
  final col = context.col;
  final info = ErrorInfoUI.fromError(
    context,
    error,
    unseriousBackground: col.onSurface,
    unseriousForeground: col.surface,
    seriousBackground: col.error,
    seriousForeground: col.onError,
  );

  final actions = resolveErrorAction(context, info);

  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(12)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: actions.isEmpty ? 16 : 8,
      ),
      duration: const Duration(seconds: 10),
      backgroundColor: info.backgroundColor,
      content: Row(
        spacing: 8,
        children: [
          Icon(
            info.icon,
            color: info.foregroundColor,
          ),
          Expanded(
            child: Text(
              '${message != null ? '$message: ' : ''}${info.text}',
              style: TextStyle(color: info.foregroundColor),
              maxLines: 5,
            ),
          ),
          ...actions,
        ],
      ),
    ),
  );
}

void showMessage(
  BuildContext context,
  String message, {
  Duration? duration,
  bool isPersistent = false,
  bool showLoading = false,
  List<Widget> actions = const [],
}) {
  if (!context.mounted) return;

  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(12)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: actions.isEmpty ? 16 : 8,
      ),
      duration: duration ?? const Duration(seconds: 3),
      persist: isPersistent,
      content: Row(
        spacing: 8,
        children: [
          Expanded(
            child: Text(message, maxLines: 5),
          ),
          ...actions,
          if (showLoading)
            ExpressiveLoadingIndicator(
              size: 36,
              color: context.col.onPrimary,
            ),
        ],
      ),
    ),
  );
}
