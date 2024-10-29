import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:school_manager/data/exams_data/exam_database.dart';
import 'package:school_manager/data/homeworks_data/hw_database.dart';
import 'package:school_manager/data/settings_database.dart';
import 'package:school_manager/data/subjects_data/subject_database.dart';
import 'package:school_manager/notifications/notification_controller.dart';
import 'package:school_manager/screens/calendar/calendar_screen.dart';
import 'package:school_manager/widgets/nav_bar.dart';
import 'package:school_manager/screens/homeworks/homeworks_screen.dart';
import 'package:school_manager/screens/exams/exams_screen.dart';
import 'package:school_manager/screens/home/home_screen.dart';
import 'package:school_manager/widgets/drawer/my_drawer.dart';

class TasksApp extends StatefulWidget {
  const TasksApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  State<TasksApp> createState() => _TasksAppState();
}

class _TasksAppState extends State<TasksApp> {
  Widget screenWidget = const HomeworksScreen();
  String appBarTitle = '';
  int currentScreenIndex = 0;

  final SettingsDatabase _settings = SettingsDatabase();
  late ThemeMode themeMode = _getThemeMode(_settings.get(DbKeys.themeMode));

  ThemeMode _getThemeMode(bool? value) {
    switch (value) {
      case null:
        return ThemeMode.system;

      case true:
        return ThemeMode.dark;

      case false:
        return ThemeMode.light;
    }
  }

  @override
  void initState() {
    super.initState();

    if (_settings.firstTimeOpeningApp) {
      firstTimeOpeningApp();
    }

    // Only after at least the action method is set, the notification events are delivered
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
      onNotificationCreatedMethod:
          NotificationController.onNotificationCreatedMethod,
      onNotificationDisplayedMethod:
          NotificationController.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod:
          NotificationController.onDismissActionReceivedMethod,
    );
  }

  void firstTimeOpeningApp() {
    // _settings.createInitialData();
    HomeworksDatabase().createInitialData();
    ExamDatabase().createInitialData();
    SubjectDatabase().createInitialData();
  }

  void setThemeMode(bool? value) {
    setState(() {
      themeMode = _getThemeMode(value);
    });
  }

  void switchScreen({required int newScreenIndex}) {
    setState(() {
      currentScreenIndex = newScreenIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (currentScreenIndex) {
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
          Locale('cs'),
        ],
        locale: const Locale('en', 'GB'),
        // locale: const Locale('cs', 'CZ'),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: lightDynamic ??
              ColorScheme.fromSeed(
                seedColor: Colors.deepPurpleAccent,
              ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: darkDynamic ??
              ColorScheme.fromSeed(
                seedColor: Colors.deepPurpleAccent,
                brightness: Brightness.dark,
              ),
          useMaterial3: true,
        ),
        themeMode: themeMode,
        navigatorKey: TasksApp.navigatorKey,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (context) => HomeScreen());

            case '/calendar':
              switchScreen(newScreenIndex: 1);

            // return MaterialPageRoute(builder: (context) {
            //   final ReceivedAction receivedAction =
            //       settings.arguments as ReceivedAction;
            //   return Scaffold(body: CalendarScreen(), appBar: AppBar(),);
            // });

            default:
              assert(false, 'Page ${settings.name} not found');
              return null;
          }
          return null;
        },
        home: Scaffold(
          body: screenWidget,
          appBar: AppBar(title: Text(appBarTitle)),
          drawer: MyDrawer(setThemeMode: setThemeMode),
          bottomNavigationBar: NavBar(
            onTap: switchScreen,
            initialIndex: currentScreenIndex,
          ),
        ),
      );
    });
  }
}
