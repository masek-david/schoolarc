import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_manager/data/exams_data/exam_model.dart';
import 'package:school_manager/data/homeworks_data/hw_model.dart';
import 'package:school_manager/data/settings_database.dart';
import 'package:school_manager/data/subjects_data/subject_model.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  // init hive
  await Hive.initFlutter();

  // open a box
  Hive.registerAdapter(HomeworkAdapter());
  Hive.registerAdapter(ExamAdapter());
  Hive.registerAdapter(SubjectAdapter());
  await Future.wait([
    Hive.openBox('myBox'),
    Hive.openBox('hwBox'),
    Hive.openBox('examBox'),
    // other data includes sequences and if the app is opened for the first time
    Hive.openBox('hwOtherData'),
    Hive.openBox('examOtherData'),
    Hive.openBox('settings'),
  ]);

  await AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
    'resource://drawable/logo',
    // null,
    [
      NotificationChannel(
        channelGroupKey: 'persistent_channel_group',
        channelKey: 'persistent_channel',
        channelName: 'Quick add',
        channelDescription: 'Here you can quickly add homeworks and exams',
        defaultColor: const Color(0xFF9D50DD),
        ledColor: Colors.white,
      ),
      NotificationChannel(
        onlyAlertOnce: true,
        channelGroupKey: 'tommorrow_channel_group',
        channelKey: 'tommorrow_channel',
        channelName: 'Upcoming day notifications',
        channelDescription: 'Here you will find upcoming exams and homeworks',
        defaultColor: const Color(0xFF9D50DD),
        ledColor: Colors.white,
      ),
    ],
    // Channel groups are only visual and are not required
    channelGroups: [
      NotificationChannelGroup(
        channelGroupKey: 'persistent_channel_group',
        channelGroupName: 'Add from notifications',
      ),
      NotificationChannelGroup(
        channelGroupKey: 'tommorrow_channel_group',
        channelGroupName: 'Upcoming day',
      ),
    ],
    debug: true,
  );

  SettingsDatabase settings = SettingsDatabase();

  if(settings.firstTimeOpeningApp()){
    firstTimeOpeningApp(settings);
  }

  // gets rid of android bottom colored bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      // systemStatusBarContrastEnforced: true,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top]);

  runApp(const TasksApp());
}

void firstTimeOpeningApp(SettingsDatabase settings){
  settings.createInitialData();
}