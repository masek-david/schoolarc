import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_manager/exams/data/exam_model.dart';
import 'package:school_manager/homeworks/data/hw_model.dart';
import 'package:school_manager/subjects/subject_model.dart';
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
    Hive.openBox('hwSequenceBox'),
  ]);

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
