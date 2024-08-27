import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:school_manager/screens/calendar/calendar_screen.dart';
import 'package:school_manager/widgets/nav_bar.dart';
import 'package:school_manager/screens/homeworks/homeworks_screen.dart';
import 'package:school_manager/screens/exams/exams_screen.dart';
import 'package:school_manager/screens/home/home_screen.dart';
import 'package:school_manager/widgets/drawer/my_drawer.dart';

class TasksApp extends StatefulWidget {
  const TasksApp({super.key});

  @override
  State<TasksApp> createState() => _TasksAppState();
}

class _TasksAppState extends State<TasksApp> {
  Widget screenWidget = const HomeworksScreen();
  String appBarTitle = '';
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
        screenWidget = HomeScreen();
        appBarTitle = 'Home';
        break;
      case 1:
        screenWidget = const CalendarScreen();
        appBarTitle = 'Calendar';
      case 2:
        screenWidget = const HomeworksScreen();
        appBarTitle = 'Homeworks';
        break;
      case 3:
        screenWidget = const ExamsScreen();
        appBarTitle = 'Exams';
        break;
    }

    return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      return MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // English
        ],
        locale: const Locale('en', 'GB'),
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
          appBar: AppBar(title: Text(appBarTitle)),
          drawer: const MyDrawer(),
          bottomNavigationBar: NavBar(onTap: switchScreen),
        ),
      );
    });
  }
}
