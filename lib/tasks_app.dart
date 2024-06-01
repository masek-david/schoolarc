import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:school_manager/util/nav_bar.dart';
import 'package:school_manager/screens/homeworks_screen.dart';
import 'package:school_manager/screens/exams_screen.dart';
import 'package:school_manager/screens/home_screen.dart';

class TasksApp extends StatefulWidget {
  // or schoolman?
  const TasksApp({super.key});

  @override
  State<TasksApp> createState() => _TasksAppState();
}

class _TasksAppState extends State<TasksApp> {
  Widget screenWidget = const HomeworksScreen();
  int currentScreen = 1;

  void switchScreen({required int newScreenIndex}) {
    setState(() {
      currentScreen = newScreenIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (currentScreen) {
      case 0:
        screenWidget = const HomeScreen();
        break;
      case 1:
        screenWidget = const HomeworksScreen();
        break;
      case 2:
        screenWidget = const ExamsScreen();
    }

    return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: lightDynamic,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: darkDynamic,
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: Scaffold(
          body: screenWidget,
          // appBar: AppBar(title: const Text('School manager')),
          bottomNavigationBar: Navbar(onTap: switchScreen),
        ),
      );
    });
  }
}
