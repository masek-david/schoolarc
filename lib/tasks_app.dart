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
  List hwList = [
    ["Cj", "ps 12/5", "14.5.", false],
    ["Ma", "uc 23/34", "13.5.", false],
    ["Ma", "uc 23/34", "13.5.", false],
  ];
  Widget screenWidget = HomeworksScreen(hwList: hwList);
  int currentScreen = 0;


  void switchScreen({required int newScreenIndex}) {
    setState(() {
      currentScreen = newScreenIndex;
    });
  }

  // void addHWtoList(String hwName) {
  //   HomeworksScreen.createNewHW();
  // }

  @override
  Widget build(BuildContext context) {

    switch (currentScreen) {
      case 0:
        screenWidget = HomeworksScreen();
        break;
      case 1:
        screenWidget = const ExamsScreen();
    }

    return MaterialApp(
      home: Scaffold(
        body: screenWidget,
        floatingActionButton: const MyFAB(),
        appBar: AppBar(title: const Text('School manager')),
        bottomNavigationBar: Navbar(onTap: switchScreen),
      ),
    );
  }
}
