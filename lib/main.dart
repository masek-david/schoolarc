import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/services/firestore/firebase_options.dart';
import 'package:school_manager/models/exams/exam_model.dart';
import 'package:school_manager/models/homeworks/hw_model.dart';
import 'package:school_manager/models/logs/log_model.dart';
import 'package:school_manager/models/subjects/subject_model.dart';
import 'package:school_manager/models/timetable/lesson_times_model.dart';
import 'package:school_manager/models/timetable/table_model.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  FlutterError.onError = (details) async {
    FlutterError.presentError(details); // Current error

    String text =
        '${details.exception.toString()}\n\n ${details.stack.toString()}\nlibrary: ${details.library}\n\ncontext: ';

    text += details.context?.value.toString() ?? '';

    logsService.save(text);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    logsService
        .save('platform dispatcher: ${error.toString()}\n${stack.toString()}');
    return true;
  };

  // init hive
  await Hive.initFlutter();

  Hive.registerAdapter(HomeworkAdapter());
  Hive.registerAdapter(ExamAdapter());
  Hive.registerAdapter(SubjectAdapter());
  Hive.registerAdapter(TimeTableAdapter());
  Hive.registerAdapter(LessonTimesAdapter());
  Hive.registerAdapter(LogAdapter());

  await Future.wait([
    Hive.openBox('subjectBox'),
    Hive.openBox('hwBox'),
    Hive.openBox('examBox'),
    Hive.openBox('tableBox'),
    // other data includes sequences
    Hive.openBox('hwOtherData'),
    Hive.openBox('examOtherData'),
    Hive.openBox('subjectOtherData'),

    Hive.openBox('bakaAddedHw'),
    Hive.openBox('bakaSeenHw'),

    Hive.openBox('settings'),
    Hive.openBox('logBox'),
  ]);

  await AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
    'resource://drawable/res_app_icon',
    // null,
    [
      NotificationChannel(
        onlyAlertOnce: true,
        channelGroupKey: 'tommorrow_channel',
        channelKey: 'tommorrow_channel',
        channelName: 'Upcoming day notifications',
        channelDescription: 'Here you will find upcoming exams and homeworks',
        defaultColor: Colors.transparent,
        ledColor: Colors.blue,
      ),
      NotificationChannel(
        onlyAlertOnce: true,
        channelGroupKey: 'main_channel',
        channelKey: 'main_channel',
        channelName: 'Main channel',
        channelDescription: 'Main channel for notifications',
        defaultColor: Colors.transparent,
        ledColor: Colors.blue,
      ),
    ],
    // Channel groups are only visual and are not required
    channelGroups: [
      NotificationChannelGroup(
        channelGroupKey: 'tommorrow_channel',
        channelGroupName: 'Upcoming day',
      ),
    ],
    debug: true,
  );

  // gets rid of android bottom colored bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      // systemStatusBarContrastEnforced: true,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top]);

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ProviderScope(child: const TasksApp()),
  );
}
