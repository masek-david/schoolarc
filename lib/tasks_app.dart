import 'package:flutter/material.dart';
import 'package:school_manager/nav_bar.dart';
import 'package:school_manager/homeworks_screen.dart';
import 'package:school_manager/exams_screen.dart';
import 'package:school_manager/fab.dart';

class TasksApp extends StatefulWidget {
  const TasksApp({super.key});

  @override
  State<TasksApp> createState() => _TasksAppState();
}

class _TasksAppState extends State<TasksApp> {
  Widget screenWidget = const HomeworksScreen();
  int currentScreen = 0;

  void switchScreen({required int newScreenIndex}) {
    setState(() {
      currentScreen = newScreenIndex;
    });
  }

  @override
  Widget build(BuildContext context) {

    switch (currentScreen) {
      case 0:
        screenWidget = const HomeworksScreen();
        break;
      case 1:
        screenWidget = const ExamsScreen();
    }

    return MaterialApp(
      
      home: Scaffold(
        body: screenWidget,
        floatingActionButton: const MyFAB(),
        bottomNavigationBar: Navbar(onTap: switchScreen),
      ),
    );
  }
}
