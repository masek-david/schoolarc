import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/data/bakalari/baka_service.dart';
import 'package:school_manager/data/exams_data/exam_dto_model.dart';
import 'package:school_manager/data/exams_data/exam_service.dart';
import 'package:school_manager/data/homeworks_data/hw_dto_model.dart';
import 'package:school_manager/data/homeworks_data/hw_service.dart';
import 'package:school_manager/data/settings_database.dart';
import 'package:school_manager/data/stravacz/strava_service.dart';
import 'package:school_manager/data/subjects_data/subject_service.dart';
import 'package:school_manager/data/table_data/timetable_database.dart';
import 'package:school_manager/notifications/notification_controller.dart';
import 'package:school_manager/screens/calendar/calendar_screen.dart';
import 'package:school_manager/screens/intro/intro_screen.dart';
import 'package:school_manager/theme_generate.dart';
import 'package:school_manager/widgets/add_bottom_sheet/add_bottom_sheet.dart';
import 'package:school_manager/widgets/nav_bar.dart';
import 'package:school_manager/screens/homeworks/homeworks_screen.dart';
import 'package:school_manager/screens/exams/exams_screen.dart';
import 'package:school_manager/screens/home/home_screen.dart';
import 'package:school_manager/widgets/drawer/my_drawer.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final settings = SettingsDatabase();
final homeworkService = HomeworkService();
final examService = ExamService();
final subjectService = SubjectService();
final timetableDatabase = TimeTableDatabase();
final bakaService = BakaService();
final stravaService = StravaService();

Future<void> addTask(
  BuildContext context, {
  required bool isHomework,
  DateTime? initialDate,
}) async {
  initialDate ??= DateTime.now();

  await showAddBottomSheet(
    context,
    initialDate: initialDate,
    onSave: ({required date, required priority, subject, required text}) async {
      isHomework
          ? await homeworkService.saveNewHW(
              date: date, priority: priority, subject: subject, text: text)
          : await examService.saveNewExam(
              date: date, priority: priority, subject: subject, text: text);
    },
  );

  return;
}

Future<void> editHw(BuildContext context, int dbIndex) async {
  HomeworkDTO hw = homeworkService.getHomework(dbIndex);

  await showAddBottomSheet(
    context,
    initialDate: hw.deadline,
    initialSubject: hw.subject,
    initialPriority: hw.priority,
    initialName: hw.text,
    onSave: ({required date, required priority, subject, required text}) {
      homeworkService.saveEditedHW(
        date: date,
        priority: priority,
        subject: subject,
        text: text,
        completion: false,
        dbIndex: dbIndex,
      );
    },
  );
  return;
}

Future<void> editExam(BuildContext context, int dbIndex) async {
  ExamDTO exam = examService.getExam(dbIndex);

  await showAddBottomSheet(
    context,
    initialDate: exam.deadline,
    initialSubject: exam.subject,
    initialPriority: exam.priority,
    initialName: exam.text,
    onSave: ({required date, required priority, subject, required text}) {
      examService.saveEditedExam(
        date: date,
        priority: priority,
        subject: subject,
        text: text,
        dbIndex: dbIndex,
      );
    },
  );

  return;
}

void changeCompletion(int dbIndex, bool value) {
  homeworkService.changeCompletion(dbIndex, value);
}

Future<void> deleteHw(
    BuildContext context, int dbIndex, Function onDeleteRevert) async {
  homeworkService.deleteHw(dbIndex);
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text('Homework deleted'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          homeworkService.revertLastlyDeletedHw();
          onDeleteRevert();
        },
      ),
    ),
  );

  return;
}

Future<void> deleteExam(
    BuildContext context, int dbIndex, Function onDeleteRevert) async {
  examService.deleteExam(dbIndex);
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text('Exam deleted'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          examService.revertLastlyDeletedExam();
          onDeleteRevert();
        },
      ),
    ),
  );

  return;
}

void showMessage(
  BuildContext context,
  String message, {
  bool isError = false,
  bool isContinuos = false,
}) {
  if (context.mounted) {
    final duration = isError
        ? const Duration(seconds: 5)
        : isContinuos
            ? const Duration(days: 1)
            : const Duration(seconds: 1);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        backgroundColor:
            isError ? Theme.of(context).colorScheme.errorContainer : null,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                message,
                maxLines: 5,
                style: TextStyle(
                  color: isError
                      ? Theme.of(context).colorScheme.onErrorContainer
                      : null,
                ),
              ),
            ),
            if (isContinuos)
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
          ],
        ),
      ),
    );
  }
}

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
  bool calendarShowTommorrow = false;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // This code will run after the first frame is rendered.
      calendarShowTommorrow = false;
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
      var defaultThemeLight = ColorScheme.fromSeed(
        seedColor: Colors.deepPurpleAccent,
        brightness: Brightness.light,
      );
      var defaultThemeDark = ColorScheme.fromSeed(
        seedColor: Colors.deepPurpleAccent,
        brightness: Brightness.dark,
      );

      lightDynamic ??= defaultThemeLight;
      darkDynamic ??= defaultThemeDark;

      (ColorScheme, ColorScheme) schemes = generateDynamicColourSchemes(
        lightDynamic,
        darkDynamic,
      );

      final light = schemes.$1;
      final dark = schemes.$2;

      return MaterialApp(
        navigatorKey: navigatorKey,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // English
          // Locale('cs'),
        ],
        locale: const Locale('en', 'GB'),
        // locale: const Locale('cs', 'CZ'),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: light),
        darkTheme: ThemeData(colorScheme: dark),
        // darkTheme: ThemeData(colorScheme: darkDynamic),
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
              calendarShowTommorrow = true;
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
          body: SlidableAutoCloseBehavior(
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              children: [
                HomeScreen(switchDrawer: switchDrawer),
                CalendarScreen(
                  switchDrawer: switchDrawer,
                  showTommorrow: calendarShowTommorrow,
                ),
                HomeworksScreen(switchDrawer: switchDrawer),
                ExamsScreen(switchDrawer: switchDrawer),
              ],
            ),
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
