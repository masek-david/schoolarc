import 'package:flutter/material.dart';
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
  await Hive.openBox('myBox');

  runApp(const TasksApp());
}
