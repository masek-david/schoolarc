import 'package:flutter/material.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  // init hive
  await Hive.initFlutter();

  // open a box
  var box = await Hive.openBox('myBox');
  
  runApp(const TasksApp());
}