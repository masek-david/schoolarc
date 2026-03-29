import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:home_widget/home_widget.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/provider/bakalari/baka_homeworks_notifier.dart';
import 'package:schoolarc/provider/bakalari/current_timetable_notifier.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/provider/strava/strava_meals_notifier.dart';
import 'package:schoolarc/provider/subject_notifier.dart';
import 'package:schoolarc/screens/app_info_screen.dart';
import 'package:schoolarc/screens/firebase/cloudsync_login_screen.dart';
import 'package:schoolarc/screens/main_screens/calendar/calendar_screen.dart';
import 'package:schoolarc/screens/main_screens/exams_screen.dart';
import 'package:schoolarc/screens/main_screens/home/home_screen.dart';
import 'package:schoolarc/screens/main_screens/homeworks_screen.dart';
import 'package:schoolarc/screens/onboarding/onboarding.dart';
import 'package:schoolarc/services/firebase/app_info_notifier.dart';
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
  late RestorableInt currentPageIndex = RestorableInt(
    settings.get(Setting.initialAppPage),
  );
  bool showingOnboarding = false;

  void endOnboarding() {
    setState(() {
      showingOnboarding = false;
    });
  }

  // called when user closes the app and when user opens the app
  void _onAppLeaveOrReturn(bool nowActive) {
    updateMainWidget(ref);
    NotificationSender.scheduleUpcomingDayNotifications(context);

    if (nowActive) {
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) {
          ref
              .read(
                actualTimetableDataProvider(
                  getCurrentTimetableWeekIndex(),
                ).notifier,
              )
              .refreshIfOld();
          ref.read(bakaHomeworksProvider.notifier).refreshIfOld();
          ref.read(stravaMealsProvider.notifier).refreshIfOld();
          ref.read(examDataProvider.notifier).checkAllIfCompleted();
        },
      );
    }
  }

  void switchPage({required int newScreenIndex}) {
    setState(() {
      currentPageIndex.value = newScreenIndex;
    });

    // try refreshing data for homescreen
    if (newScreenIndex == 0) {
      ref
          .read(
            actualTimetableDataProvider(
              getCurrentTimetableWeekIndex(),
            ).notifier,
          )
          .refreshIfOld();
      ref.read(stravaMealsProvider.notifier).refreshIfOld();
    }
  }

  // runs frame after first frame drawed
  void onAppStart({required bool firstTimeOpeningApp}) {
    updateMainWidget(ref);
    NotificationSender.scheduleUpcomingDayNotifications(context);
    ref.read(examDataProvider.notifier).checkAllIfCompleted();
    ref.read(bakaHomeworksProvider.notifier);

    if (!firstTimeOpeningApp && mounted) {
      // ask for notifications
      if (settings.get(Setting.stopAskingForNotifications) != true) {
        NotificationSender.getPermission(context, tomorrowChannel);
      }

      // ask to verify email
      if (fireService.needsVerification) {
        final user = fireService.user;
        if (user != null) {
          verifyEmail(context, ref, user);
        }
      }

      // show warning to enable cloud sync on web
      if (kIsWeb &&
          !settings.get(Setting.stopPwaCloudSyncWarning) &&
          !fireService.hasUser) {
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
    }
  }

  Locale? _lastLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final locale = context.locale;

    // update widgets localization strings
    if (_lastLocale != locale) {
      _lastLocale = locale;
      widgetSaveLocalizationStrings(context);
    }
  }

  @override
  void initState() {
    super.initState();

    final firstTimeOpeningApp = settings.firstTimeOpeningApp;

    appStateListener = AppLifecycleListener(
      onResume: () => _onAppLeaveOrReturn(true),
      onInactive: () => _onAppLeaveOrReturn(false),
    );

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        onAppStart(firstTimeOpeningApp: firstTimeOpeningApp);
      },
    );

    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      HomeWidget.initiallyLaunchedFromHomeWidget().then((event) {
        if (event != null && navigatorKey.currentContext?.mounted == true) {
          handleWidgetClick(event, navigatorKey.currentContext!, ref);
        }
      });

      HomeWidget.widgetClicked.listen((event) {
        if (event != null && navigatorKey.currentContext?.mounted == true) {
          handleWidgetClick(event, navigatorKey.currentContext!, ref);
        }
      });
    }

    if (firstTimeOpeningApp || settings.get(.onboardingProgress) != null) {
      showingOnboarding = true;
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

  final screens = [
    const HomeScreen(),
    const CalendarScreen(),
    const HomeworksScreen(),
    const ExamsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = context.isWide;
    final miliseconds =
        (settings.get(Setting.pageSwitchAnimationDuration) as double).toInt();

    ref.listen(
      appInfoProvider,
      (previous, next) {
        final message = next.value?.message;

        if (message != null && message != settings.get(.lastSeenMessage)) { 
          settings.save(.lastSeenMessage, message);

          showDialogAdaptive(
            context: context,
            content: Text(next.value!.message!),
            actions: [
              adaptiveDialogButton(
                context: context,
                child: Text(context.loc.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        }
      },
    );

    return Stack(
      children: [
        MyShortcuts(
          child: Scaffold(
            key: _scaffoldKey,
            appBar: !isWide
                ? AppBar(
                    scrolledUnderElevation: 0,
                    backgroundColor: context.col.surface,
                    leading:
                        (ref.watch(subjectsNonDeletedProvider).isEmpty ||
                            timetableDb.timeTable.lessonTimes.isEmpty)
                        ? const Align(
                            alignment: .center,
                            child: Badge(
                              alignment: Alignment(0.6, -0.6),
                              backgroundColor: Colors.red,
                              child: DrawerButton(),
                            ),
                          )
                        : null,
                  )
                : null,
            body: SlidableAutoCloseBehavior(
              child: Row(
                children: [
                  if (isWide)
                    SideNavBar(
                      onTap: switchPage,
                      pageIndex: currentPageIndex.value,
                    ),
                  WideScreenBorders(
                    show: isWide,
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: miliseconds),
                      switchInCurve: Curves.easeOutSine,
                      transitionBuilder: (child, animation) {
                        // TODO test device
                        return AnimatedBuilder(
                          animation: animation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: animation.value,
                              child: child,
                            );
                          },
                          child: child,
                        );

                        
                        // return AnimatedBuilder(
                        //   animation: animation,
                        //   builder: (context, child) {
                        //     return Padding(
                        //       padding: EdgeInsets.only(
                        //         top: (animation.value - 1) * -50,
                        //       ),
                        //       child: child,
                        //     );
                        //   },
                        //   child: child,
                        // );
                      },
                      child: screens[currentPageIndex.value],
                    ),
                  ),
                ],
              ),
            ),
            drawer: const MyDrawer(),
            bottomNavigationBar: isWide
                ? null
                : BottomNavBar(
                    onTap: switchPage,
                    pageIndex: currentPageIndex.value,
                  ),
          ),
        ),
        if (showingOnboarding) Onboarding(closeOnboarding: endOnboarding),
        if (ref.watch(needsUpdateProvider)) const AppInfoScreen(),
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
