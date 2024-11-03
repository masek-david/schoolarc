import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:school_manager/data/settings_database.dart';
import 'package:school_manager/notifications/notification_controller.dart';
import 'package:school_manager/screens/calendar/calendar_screen.dart';
import 'package:school_manager/screens/intro/intro_screen.dart';
import 'package:school_manager/widgets/nav_bar.dart';
import 'package:school_manager/screens/homeworks/homeworks_screen.dart';
import 'package:school_manager/screens/exams/exams_screen.dart';
import 'package:school_manager/screens/home/home_screen.dart';
import 'package:school_manager/widgets/drawer/my_drawer.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class TasksApp extends StatefulWidget {
  const TasksApp({super.key});

  @override
  State<TasksApp> createState() => _TasksAppState();
}

class _TasksAppState extends State<TasksApp> {
  late final _pageController = PageController(
    initialPage: _settings.get(Setting.initialAppPage),
  );
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final SettingsDatabase _settings = SettingsDatabase();
  late ThemeMode themeMode = _getThemeMode(_settings.get(Setting.themeMode));
  late int currentPageIndex = _settings.get(Setting.initialAppPage);
  // late final initialPage =

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

    firstTimeOpeningApp();
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
    navigatorKey.currentState?.push(MaterialPageRoute(
      builder: (context) => const IntroScreen(),
    ));
  }

  void setThemeMode(bool? value) {
    setState(() {
      themeMode = _getThemeMode(value);
    });
  }

  void switchScreen({required int newScreenIndex}) {
    late final pageSwitchAnimationDuration = Duration(
      milliseconds:
          (_settings.get(Setting.pageSwitchAnimationDuration) as double)
              .toInt(),
    );

    if (pageSwitchAnimationDuration.inMilliseconds == 0) {
      _pageController.jumpToPage(newScreenIndex);
    } else {
      _pageController.animateToPage(
        newScreenIndex,
        curve: Curves.easeInOut,
        duration: pageSwitchAnimationDuration,
      );
    }

    setState(() {
      currentPageIndex = newScreenIndex;
    });
  }

  void switchDrawer({bool? close}) {
    if (_scaffoldKey.currentState?.isDrawerOpen == true || close == true) {
      _scaffoldKey.currentState?.closeDrawer();
    } else {
      _scaffoldKey.currentState?.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      return MaterialApp(
        navigatorKey: navigatorKey,
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
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(
                builder: (context) => HomeScreen(
                  switchDrawer: switchDrawer,
                ),
              );

            case '/calendar':
              navigatorKey.currentState?.popUntil((route) => route.isFirst);
              switchDrawer(close: true);
              switchScreen(newScreenIndex: 1);
              break;

            default:
              assert(false, 'Page ${settings.name} not found');
              return null;
          }
          return null;
        },
        home: Scaffold(
          key: _scaffoldKey,
          body: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _pageController,
            children: [
              HomeScreen(switchDrawer: switchDrawer),
              CalendarScreen(switchDrawer: switchDrawer),
              HomeworksScreen(switchDrawer: switchDrawer),
              ExamsScreen(switchDrawer: switchDrawer),
            ],
          ),
          drawer: MyDrawer(
            setThemeMode: setThemeMode,
          ),
          bottomNavigationBar: NavBar(
            onTap: switchScreen,
            pageIndex: currentPageIndex,
          ),
        ),
      );
    });
  }
}
