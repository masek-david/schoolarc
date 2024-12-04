import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/services/bakalari/baka_service.dart';
import 'package:school_manager/models/exams/exam_dto_model.dart';
import 'package:school_manager/services/exams/exam_service.dart';
import 'package:school_manager/models/homeworks/hw_dto_model.dart';
import 'package:school_manager/services/homeworks/hw_service.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/services/settings_database.dart';
import 'package:school_manager/services/strava_service.dart';
import 'package:school_manager/services/subjects/subject_service.dart';
import 'package:school_manager/services/timetable_database.dart';
import 'package:school_manager/models/task_model.dart';
import 'package:school_manager/utils/notifications/notification_controller.dart';
import 'package:school_manager/screens/calendar/calendar_screen.dart';
import 'package:school_manager/utils/theme_generate.dart';
import 'package:school_manager/widgets/add_bottom_sheet/add_bottom_sheet.dart';
import 'package:school_manager/widgets/nav_bar.dart';
import 'package:school_manager/screens/homeworks/homeworks_screen.dart';
import 'package:school_manager/screens/exams/exams_screen.dart';
import 'package:school_manager/screens/home/home_screen.dart';
import 'package:school_manager/widgets/drawer/my_drawer.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final scaffoldKey = GlobalKey<ScaffoldState>();
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
  Task? newTask;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => AddTaskBottomSheet(
      initialDate: initialDate,
      onSave: ({required date, required priority, subject, required text, required description}) {
        newTask = Task(
          subject: subject,
          text: text,
          deadline: date,
          description: description,
          completion: false,
          priority: TaskPriority(priority, context),
          dbIndex: 0,
        );
      },
    ),
  );

  if (newTask == null) {
    return;
  }

  if (isHomework) {
    await homeworkService.saveNewHW(
      date: newTask!.deadline,
      priority: newTask!.priority.index,
      subject: newTask!.subject,
      text: newTask!.text,
      description: newTask!.description,
    );
  } else {
    await examService.saveNewExam(
      date: newTask!.deadline,
      priority: newTask!.priority.index,
      subject: newTask!.subject,
      text: newTask!.text,
      description: newTask!.description,
    );
  }

  return;
}

Future<void> editHw(BuildContext context, int dbIndex) async {
  HomeworkDTO hw = homeworkService.getHomework(dbIndex, context);

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => AddTaskBottomSheet(
      initialSubject: hw.subject,
      initialPriority: hw.priority.index,
      initialName: hw.text,
      initialDate: hw.deadline,
      initialDescription: hw.description,
      onSave: ({required date, required priority, subject, required text, required description}) {
        hw.deadline = date;
        hw.priority = TaskPriority(priority, context);
        hw.subject = subject;
        hw.text = text;
        hw.description = description;
      },
    ),
  );

  await homeworkService.saveEditedHW(
    date: hw.deadline,
    priority: hw.priority.index,
    subject: hw.subject,
    text: hw.text,
    description: hw.description,
    dbIndex: dbIndex,
  );

  return;
}

Future<void> editExam(BuildContext context, int dbIndex) async {
  ExamDTO exam = examService.getExam(dbIndex, context);

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => AddTaskBottomSheet(
      initialSubject: exam.subject,
      initialPriority: exam.priority.index,
      initialName: exam.text,
      initialDescription: exam.description,
      initialDate: exam.deadline,
      onSave: ({required date, required priority, subject, required text, required description}) {
        exam.deadline = date;
        exam.priority = TaskPriority(priority, context);
        exam.subject = subject;
        exam.text = text;
        exam.description = description;
      },
    ),
  );
  await examService.saveEditedExam(
    date: exam.deadline,
    priority: exam.priority.index,
    subject: exam.subject,
    text: exam.text,
    description: exam.description,
    dbIndex: dbIndex,
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

void switchDrawer({bool? onlyClose}) {
  if (scaffoldKey.currentState?.isDrawerOpen == true || onlyClose == true) {
    scaffoldKey.currentState?.closeDrawer();
  } else {
    scaffoldKey.currentState?.openDrawer();
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

  final SettingsDatabase _settings = SettingsDatabase();
  late int currentPageIndex = _settings.get(Setting.initialAppPage);
  bool calendarShowTommorrow = false;

  late ThemeMode themeMode = _getThemeMode(_settings.get(Setting.themeMode));
  late Color userColor = Color(settings.get(Setting.themeColorValue));

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
    // TODO
    // navigatorKey.currentState?.push(MaterialPageRoute(
    //   builder: (context) => WelcomeScreen(),
    // ));
  }

  void refreshTheme() {
    setState(() {
      userColor = Color(settings.get(Setting.themeColorValue));
      themeMode = _getThemeMode(settings.get(Setting.themeMode));
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

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      final int dynamicSchemeVariant =
          settings.get(Setting.themeDynamicSchemeVariantInt);

      var defaultThemeLight = ColorScheme.fromSeed(
        seedColor: userColor,
        brightness: Brightness.light,
        dynamicSchemeVariant: DynamicSchemeVariant.values[dynamicSchemeVariant],
      );
      var defaultThemeDark = ColorScheme.fromSeed(
        seedColor: userColor,
        brightness: Brightness.dark,
        dynamicSchemeVariant: DynamicSchemeVariant.values[dynamicSchemeVariant],
      );

      if (settings.get(Setting.themeUseMaterial)) {
        if (lightDynamic != null && darkDynamic != null) {
          defaultThemeLight = lightDynamic;
          defaultThemeDark = darkDynamic;
        }
      }

      (ColorScheme, ColorScheme) schemes = generateDynamicColourSchemes(
        defaultThemeLight,
        defaultThemeDark,
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
        themeMode: themeMode,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              );

            case '/calendar':
              navigatorKey.currentState?.popUntil((route) => route.isFirst);
              switchDrawer(onlyClose: true);
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
          key: scaffoldKey,
          body: SlidableAutoCloseBehavior(
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              children: [
                const HomeScreen(),
                CalendarScreen(
                  showTommorrow: calendarShowTommorrow,
                ),
                const HomeworksScreen(),
                const ExamsScreen(),
              ],
            ),
          ),
          drawer: MyDrawer(
            setThemeMode: refreshTheme,
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
