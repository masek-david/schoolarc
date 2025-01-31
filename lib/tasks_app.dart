import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/provider/exam_notifier.dart';
import 'package:school_manager/provider/hw_notifier.dart';
import 'package:school_manager/provider/subject_notifier.dart';
import 'package:school_manager/screens/baka_homeworks/baka_homeworks_screen.dart';
import 'package:school_manager/screens/welcome_screen/welcome_screen.dart';
import 'package:school_manager/services/baka_homeworks_service.dart';
import 'package:school_manager/services/bakalari/baka_service.dart';
import 'package:school_manager/services/firestore/firestore_service.dart';
import 'package:school_manager/services/logs_service.dart';
import 'package:school_manager/services/settings_database.dart';
import 'package:school_manager/services/strava_service.dart';
import 'package:school_manager/services/timetable_database.dart';
import 'package:school_manager/utils/extensions/color_extension.dart';
import 'package:school_manager/utils/notifications/notification_controller.dart';
import 'package:school_manager/screens/calendar/calendar_screen.dart';
import 'package:school_manager/utils/screen_size.dart';
import 'package:school_manager/utils/theme_generate.dart';
import 'package:school_manager/widgets/navigation_bar/bottom_nav_bar.dart';
import 'package:school_manager/screens/homeworks/homeworks_screen.dart';
import 'package:school_manager/screens/exams/exams_screen.dart';
import 'package:school_manager/screens/home/home_screen.dart';
import 'package:school_manager/widgets/drawer/my_drawer.dart';
import 'package:school_manager/widgets/navigation_bar/side_nav_bar.dart';
import 'package:school_manager/widgets/wide_screen_borders.dart';
import 'package:uuid/uuid.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final scaffoldKey = GlobalKey<ScaffoldState>();
final container = ProviderContainer();
final settings = SettingsDatabase();
final timetableDatabase = TimeTableDatabase();
final bakaService = BakaService();
final bakaHomeworkService = BakaHomeworksService();
final stravaService = StravaService();
final logsService = LogsService();
final firestoreService = FirestoreService();
final uuid = Uuid();

Future<void> syncAllTasks(WidgetRef ref) async {
  Future.wait([
    ref.read(subjectsProvider.notifier).syncAll(),
    ref.read(hwProvider.notifier).syncAll(),
    ref.read(examProvider.notifier).syncAll(),
  ]);
}

void showMessage(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 3),
  bool isError = false,
  bool isContinuos = false,
  List<Widget>? actions,
}) {
  if (context.mounted) {
    if (isError) {}
    if (isContinuos) {
      duration = const Duration(days: 100);
    }

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
            if (actions != null) ...actions,
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

void tryGettingNewHomeworks() async {
  try {
    await bakaService.getHomeworks(
      onNewFound: (numberOfNew) {
        if (navigatorKey.currentContext != null) {
          final context = navigatorKey.currentContext!;

          showMessage(
            context,
            '$numberOfNew new homework${numberOfNew == 1 ? '' : 's'} found',
            duration: Duration(days: 100),
            actions: [
              FilledButton(
                onPressed: () {
                  navigatorKey.currentState?.push(MaterialPageRoute(
                    builder: (context) => BakaHomeworksScreen(),
                  ));
                  ScaffoldMessenger.of(context).clearSnackBars();
                },
                child: Text(
                  'View',
                ),
              ),
            ],
          );
        }
      },
    );
  } on Object {
    // i dont mind this
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
  final Key _key = GlobalKey();

  final SettingsDatabase _settings = SettingsDatabase();
  late int currentPageIndex = _settings.get(Setting.initialAppPage);
  bool calendarShowTommorrow = false;

  late ThemeMode themeMode = _getThemeMode(_settings.get(Setting.themeMode));
  late Color userColor = Color(settings.get(Setting.themeColorValue));
  late bool showingTutorial;

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

  void startTutorial() {
    setState(() {
      showingTutorial = true;
    });
  }

  void endTutorial() {
    setState(() {
      showingTutorial = false;
    });
  }

  @override
  void initState() {
    super.initState();

    if (_settings.firstTimeOpeningApp) {
      firstTimeOpeningApp();
    } else {
      showingTutorial = false;
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

    tryGettingNewHomeworks();
  }

  void firstTimeOpeningApp() {
    // TODO - when done simply change the key of the value
    showingTutorial = false;
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

  void showCalendar() async {
    navigatorKey.currentState?.popUntil((route) => route.isFirst);
    switchDrawer(onlyClose: true);

    calendarShowTommorrow = true;
    _pageController.jumpToPage(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // This code will run after the first frame is rendered.
      _pageController.jumpToPage(1);
    });

    setState(() {
      currentPageIndex = 1;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // This code will run after the first frame is rendered.
      calendarShowTommorrow = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenSize.init(context);

    final isWide = ScreenSize.isWideScreen.value;

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final int dynamicSchemeVariant =
            settings.get(Setting.themeDynamicSchemeVariantInt);
        final useOled = settings.get(Setting.themeUseOled);

        var defaultThemeLight = ColorScheme.fromSeed(
          seedColor: userColor,
          brightness: Brightness.light,
          dynamicSchemeVariant:
              DynamicSchemeVariant.values[dynamicSchemeVariant],
        );
        var defaultThemeDark = ColorScheme.fromSeed(
          seedColor: userColor,
          brightness: Brightness.dark,
          dynamicSchemeVariant:
              DynamicSchemeVariant.values[dynamicSchemeVariant],
        );

        if (settings.get(Setting.themeUseDeviceColor)) {
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
        final dark = schemes.$2.copyWith(
          surface: useOled ? Colors.black : null,
          surfaceContainer: useOled ? Colors.black : null,
          surfaceContainerLow:
              useOled ? schemes.$2.surfaceContainerLow.darken(0.05) : null,
          surfaceContainerHigh:
              useOled ? schemes.$2.surfaceContainerHigh.darken(0.05) : null,
          surfaceContainerHighest:
              useOled ? schemes.$2.surfaceContainerHighest.darken(0.05) : null,
          surfaceContainerLowest:
              useOled ? schemes.$2.surfaceContainerLowest.darken(0.02) : null,
        );

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
          showPerformanceOverlay: settings.get(Setting.showDebugInfo) &&
              settings.get(Setting.debugShowPerformanceOverlay),
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
                showCalendar();
                break;

              default:
                assert(false, 'Page ${settings.name} not found');
                return null;
            }
            return null;
          },
          home: Stack(
            children: [
              Scaffold(
                key: scaffoldKey,
                body: SlidableAutoCloseBehavior(
                  child: Row(
                    children: [
                      if (isWide)
                        SideNavBar(
                          onTap: switchScreen,
                          pageIndex: currentPageIndex,
                        ),
                      WideScreenBorders(
                        show: isWide && settings.get(Setting.showAppOverlay),
                        child: PageView(
                          key: _key,
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
                    ],
                  ),
                ),
                drawer: MyDrawer(
                  setThemeMode: refreshTheme,
                  startTutorial: startTutorial,
                ),
                bottomNavigationBar: isWide
                    ? null
                    : BottomNavBar(
                        onTap: switchScreen,
                        pageIndex: currentPageIndex,
                      ),
              ),
              if (showingTutorial)
                WelcomeScreen(
                  onEnd: endTutorial,
                ),
            ],
          ),
        );
      },
    );
  }
}
