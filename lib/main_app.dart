import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/provider/bakalari/baka_homeworks_notifier.dart';
import 'package:schoolarc/provider/bakalari/current_timetable_notifier.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/hw_notifier.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/provider/strava/strava_meals_notifier.dart';
import 'package:schoolarc/screens/main_screens/calendar/calendar_screen.dart';
import 'package:schoolarc/screens/main_screens/calendar/calendar_settings.dart';
import 'package:schoolarc/screens/main_screens/exams_screen.dart';
import 'package:schoolarc/screens/main_screens/home/home_screen.dart';
import 'package:schoolarc/screens/main_screens/home/home_settings.dart';
import 'package:schoolarc/screens/main_screens/homeworks_screen.dart';
import 'package:schoolarc/screens/tutorial/tutorial.dart';
import 'package:schoolarc/services/firebase/firebase_service.dart';
import 'package:schoolarc/services/home_widget_service.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/utils/notifications/notification_controller.dart';
import 'package:schoolarc/utils/notifications/notification_sender.dart';
import 'package:schoolarc/widgets/config/my_shortcuts.dart';
import 'package:schoolarc/widgets/dialogs/show_adaptive_dialog.dart';
import 'package:schoolarc/widgets/drawer/my_drawer.dart';
import 'package:schoolarc/widgets/firebase_overlay.dart';
import 'package:schoolarc/widgets/navigation_bar/bottom_nav_bar.dart';
import 'package:schoolarc/widgets/navigation_bar/side_nav_bar.dart';
import 'package:schoolarc/widgets/wide_screen_borders.dart';

var _scaffoldKey = GlobalKey<ScaffoldState>();

void openDrawer() {
  _scaffoldKey.currentState?.openDrawer();
}

void closeDrawer() {
  _scaffoldKey.currentState?.closeDrawer();
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> with RestorationMixin {
  late final AppLifecycleListener appStateListener;

  late RestorableInt currentPageIndex =
      RestorableInt(settings.get(Setting.initialAppPage));

  bool showingTutorial = false;
  bool firstTimeOpening = false;

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

  // called when user closes the app and when user opens the app
  void _onAppLeaveOrReturn(bool nowActive) {
    updateHwWidget(ref.read(hwWidgetProvider));
    NotificationSender.scheduleUpcomingDayNotifications();

    if (nowActive) {
      ref.read(hwProvider.notifier).androidReloadBox();
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) {
          ref.read(examProvider.notifier).checkAllIfCompleted();
        },
      );
    }
  }

  void firstTimeOpeningApp() {
    firstTimeOpening = true;
    showingTutorial = true;
  }

  void switchPage({required int newScreenIndex}) {
    setState(() {
      currentPageIndex.value = newScreenIndex;
    });

    // try refreshing data for homescreen
    if (newScreenIndex == 0) {
      ref.read(currentTimetableProvider.notifier).refreshIfOld();
      ref.read(stravaMealsProvider.notifier).refreshIfOld();
    }
  }

  @override
  void initState() {
    super.initState();

    appStateListener = AppLifecycleListener(
      onResume: () => _onAppLeaveOrReturn(true),
      onInactive: () => _onAppLeaveOrReturn(false),
    );
    _onAppLeaveOrReturn(true);

    if (settings.firstTimeOpeningApp) {
      firstTimeOpeningApp();
    } else {
      if (kIsWeb &&
          !settings.get(Setting.stopPwaCloudSyncWarning) &&
          !FirebaseService.hasUser) {
        Future.delayed(
          Duration.zero,
          () {
            if (mounted) {
              showDialogAdaptive(
                context: context,
                title: Text(context.loc.cloudSyncDisabled),
                content: Text(context.loc.cloudSyncDisabledWarning),
                actions: [
                  adaptiveDialogButton(
                    context: context,
                    isDefaultAction: true,
                    child: Text(context.loc.enable),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.restorablePushNamed(context, '/cloudsync');
                    },
                  ),
                  adaptiveDialogButton(
                    context: context,
                    isDestructiveAction: true,
                    child: Text(context.loc.keepDisabled),
                    onPressed: () => Navigator.pop(context),
                  ),
                  adaptiveDialogButton(
                    context: context,
                    isDestructiveAction: true,
                    child: Text(context.loc.dontShowAgain),
                    onPressed: () {
                      settings.save(Setting.stopPwaCloudSyncWarning, true);
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            }
          },
        );
      }

      if (settings.get(Setting.stopAskingForNotifications) != true) {
        Future.delayed(
          Duration.zero,
          () {
            if (mounted) {
              NotificationSender.getPermission(context, tomorrowChannel);
            }
          },
        );
      }
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

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        ref.read(bakaHomeworksProvider.notifier);
      },
    );
  }

  @override
  void dispose() {
    currentPageIndex.dispose();
    appStateListener.dispose();
    super.dispose();
  }

  @override
  String? get restorationId => 'mainApp';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(currentPageIndex, 'currentPage');
  }

  @override
  Widget build(BuildContext context) {
    final isWide = context.isWide;

    if (ref.watch(showCalendarProvider)) {
      switchPage(newScreenIndex: 1);
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) {
          ref.read(showCalendarProvider.notifier).hide();
        },
      );
    }

    final Widget? action = switch (currentPageIndex.value) {
      0 => IconButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return const HomeSettings();
              },
            );
          },
          icon: const Icon(Icons.settings),
        ),
      1 => IconButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => const CalendarSettings(),
            );
          },
          icon: const Icon(Icons.settings),
        ),
      _ => null,
    };

    final Widget screen = switch (currentPageIndex.value) {
      0 => const HomeScreen(),
      1 => const CalendarScreen(),
      2 => const HomeworksScreen(),
      _ => const ExamsScreen(),
    };
    final miliseconds =
        (settings.get(Setting.pageSwitchAnimationDuration) as double).toInt();

    return Stack(
      children: [
        MyShortcuts(
          child: Scaffold(
            key: _scaffoldKey,
            appBar: !isWide
                ? AppBar(
                    actions: [if (action != null) action],
                    systemOverlayStyle: const SystemUiOverlayStyle(
                      statusBarColor: Colors.transparent,
                      systemNavigationBarColor: Colors.transparent,
                    ),
                  )
                : null,
            body: SlidableAutoCloseBehavior(
              child: Row(
                children: [
                  if (isWide)
                    SideNavBar(
                      onTap: switchPage,
                      pageIndex: currentPageIndex.value,
                      action: action,
                    ),
                  WideScreenBorders(
                    show: isWide,
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: miliseconds),
                      switchInCurve: Curves.easeOutSine,
                      transitionBuilder: (child, animation) {
                        return AnimatedBuilder(
                          animation: animation,
                          builder: (context, child) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  top: (animation.value - 1) * -50),
                              child: child,
                            );
                          },
                          child: child,
                        );
                      },
                      child: screen,
                    ),
                  ),
                ],
              ),
            ),
            drawer: MyDrawer(
              startTutorial: startTutorial,
            ),
            bottomNavigationBar: isWide
                ? null
                : BottomNavBar(
                    onTap: switchPage,
                    pageIndex: currentPageIndex.value,
                  ),
          ),
        ),
        if (showingTutorial)
          Tutorial(
            onEnd: endTutorial,
            firstTime: firstTimeOpening,
          ),
        if (ref.watch(debugShowFireOverlayProvider))
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: FirebaseOverlay(),
          ),
      ],
    );
  }
}
