import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:app_links/app_links.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:home_widget/home_widget.dart';
import 'package:m3e_widgets/m3e_widgets.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/features/qr_sharing/data/qr_task_parsing.dart';
import 'package:schoolarc/features/qr_sharing/presentation/qr_import_dialog.dart';
import 'package:schoolarc/features/timetable/providers/timetable_notifier.dart';
import 'package:schoolarc/provider/bakalari/baka_homeworks_notifier.dart';
import 'package:schoolarc/provider/bakalari/current_timetable_notifier.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/home_page_notifier.dart';
import 'package:schoolarc/provider/hw_notifier.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/provider/strava/strava_meals_notifier.dart';
import 'package:schoolarc/provider/subject_notifier.dart';
import 'package:schoolarc/screens/app_info_screen.dart';
import 'package:schoolarc/screens/main_screens/calendar/calendar_screen.dart';
import 'package:schoolarc/screens/main_screens/exams_screen.dart';
import 'package:schoolarc/screens/main_screens/home/home_screen.dart';
import 'package:schoolarc/screens/main_screens/homeworks_screen.dart';
import 'package:schoolarc/screens/onboarding/onboarding.dart';
import 'package:schoolarc/screens/recap/recap.dart';
import 'package:schoolarc/services/firebase/app_info_notifier.dart';
import 'package:schoolarc/services/home_widget_service.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/utils/notifications/notification_controller.dart';
import 'package:schoolarc/utils/notifications/notification_sender.dart';
import 'package:schoolarc/widgets/config/my_shortcuts.dart';
import 'package:schoolarc/widgets/dialogs/show_my_dialog.dart';
import 'package:schoolarc/widgets/drawer/my_drawer.dart';
import 'package:schoolarc/widgets/firebase_overlay.dart';
import 'package:schoolarc/widgets/navigation_bar/bottom_nav_bar.dart';
import 'package:schoolarc/widgets/navigation_bar/side_nav_bar.dart';
import 'package:schoolarc/widgets/wide_screen_borders.dart';

final _scaffoldKey = GlobalKey<ScaffoldState>();

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

class _MainAppState extends ConsumerState<MainApp> {
  late final AppLifecycleListener appStateListener;
  late final StreamSubscription<Uri>? appLinksSub;
  bool showingOnboarding = false;

  void endOnboarding() {
    setState(() {
      showingOnboarding = false;
    });
  }

  // called when user closes the app and when user opens the app
  void _onAppLeaveOrReturn(bool nowActive) {
    HomeWidgetService.updateMainWidget(ref);
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
    ref.read(homePageProvider.notifier).switchPage(newScreenIndex);

    Posthog().screen(screenName: 'Home page: $newScreenIndex');

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
    HomeWidgetService.updateMainWidget(ref);
    NotificationSender.scheduleUpcomingDayNotifications(context);
    ref.read(examDataProvider.notifier).checkAllIfCompleted();
    ref.read(bakaHomeworksProvider.notifier);

    if (!firstTimeOpeningApp && mounted) {
      // ask for notifications
      if (settings.get(Setting.stopAskingForNotifications) != true) {
        NotificationSender.getPermission(context, tomorrowChannel);
      }

      // TODO ask to verify email
      // if (fireService.needsVerification) {
      //   final user = fireService.user;
      //   if (user != null) {
      //     verifyEmail(context, ref, user);
      //   }
      // }

      // show warning to enable cloud sync on web
      if (kIsWeb &&
          !settings.get(Setting.stopPwaCloudSyncWarning) &&
          !fireService.hasUser) {
        showMyDialog(
          context: context,
          title: context.loc.cloudSyncDisabled,
          text: context.loc.cloudSyncDisabledWarning,
          actions: [
            DialogActionButton(
              isDefaultAction: true,
              text: context.loc.enable,
              onPressed: () {
                Navigator.pop(context);
                Navigator.restorablePushNamed(context, '/cloudsync');
              },
            ),
            DialogActionButton(
              isDestructiveAction: true,
              text: context.loc.keepDisabled,
              onPressed: () => Navigator.pop(context),
            ),
            DialogActionButton(
              isDestructiveAction: true,
              text: context.loc.dontShowAgain,
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
      HomeWidgetService.widgetSaveLocalizationStrings(context);
    }
  }

  @override
  void initState() {
    super.initState();

    final appLinks = AppLinks();
    appLinksSub = kIsWeb
        ? null
        : appLinks.uriLinkStream.listen((uri) {
            WidgetsBinding.instance.addPostFrameCallback(
              (timeStamp) {
                try {
                  final decoded = Uri.decodeComponent(uri.query);

                  if (decoded.startsWith('sti')) {
                    final recap = RecapData.decode(decoded);
                    Navigator.pushNamed(
                      context,
                      '/recap-sticker',
                      arguments: recap,
                    );
                  }
                  if (decoded.startsWith('sh')) {
                    final task = QrParse.fromQr(
                      decoded,
                      ref.read(subjectsSortedProvider),
                    );
                    showQrImportDialog(
                      context,
                      task,
                      (isHomework) {
                        if (isHomework) {
                          ref
                              .read(hwDataProvider.notifier)
                              .create(task.toHwData());
                        } else {
                          ref
                              .read(examDataProvider.notifier)
                              .create(task.toExamData());
                        }
                      },
                    );
                  }
                } catch (e) {
                  showErrorMessage(context, e.toString());
                }
              },
            );
          });

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
          HomeWidgetService.handleWidgetClick(
            event,
            navigatorKey.currentContext!,
            ref,
          );
        }
      });

      HomeWidget.widgetClicked.listen((event) {
        if (event != null && navigatorKey.currentContext?.mounted == true) {
          HomeWidgetService.handleWidgetClick(
            event,
            navigatorKey.currentContext!,
            ref,
          );
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
    appStateListener.dispose();
    appLinksSub?.cancel();
    super.dispose();
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
    final page = ref.watch(homePageProvider);
    final miliseconds =
        (settings.get(Setting.pageSwitchAnimationDuration) as double).toInt();

    ref.listen(
      appInfoProvider,
      (previous, next) {
        final message = next.value?.message;

        if (message != null &&
            message != '' &&
            message != settings.get(.lastSeenMessage)) {
          settings.save(.lastSeenMessage, message);

          showMyDialog(
            context: context,
            text: next.value!.message!,
            actions: [
              DialogActionButton(
                text: context.loc.close,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        }
      },
    );

    // final loc = context.loc;
    //
    // return NavigationRailScaffold(
    //   onTap: switchPage,
    //   pageIndex: page,
    //   destinations: [
    //     NavigationPrimaryDestination(
    //       icon: const Icon(Icons.home_outlined),
    //       selectedIcon: const Icon(Icons.home),
    //       label: Text(loc.home),
    //     ),
    //     NavigationPrimaryDestination(
    //       icon: const Icon(Icons.calendar_month_outlined),
    //       selectedIcon: const Icon(Icons.calendar_month),
    //       label: Text(loc.calendar),
    //     ),
    //     NavigationPrimaryDestination(
    //       icon: const Icon(Icons.home_work_outlined),
    //       selectedIcon: const Icon(Icons.home_work),
    //       label: Text(loc.homework(2)),
    //     ),
    //     NavigationPrimaryDestination(
    //       icon: const Icon(Icons.description_outlined),
    //       selectedIcon: const Icon(Icons.description),
    //       label: Text(loc.exams(2)),
    //     ),
    //     const NavigationHeader(label: Text('context.loc.other')),
    //     NavigationSecondaryDestination(
    //       label: Text(loc.subjects),
    //       icon: const Icon(Icons.school_outlined),
    //       showBadge: ref.watch(subjectsNonDeletedProvider).isEmpty,
    //       onPressed: () {
    //         Navigator.restorablePushNamed(context, '/subjects');
    //       },
    //     ),
    //     NavigationSecondaryDestination(
    //       label: Text(loc.permanentTimetable),
    //       icon: const Icon(Icons.calendar_month_outlined),
    //       showBadge: timetableDb.timeTable.lessonTimes.isEmpty,
    //       onPressed: () {
    //         Navigator.restorablePushNamed(context, '/timetable');
    //       },
    //     ),
    //     NavigationSecondaryDestination(
    //       label: Text(loc.hwFromBaka),
    //       icon: const Icon(Icons.home_work_outlined),
    //       onPressed: () {
    //         ref.read(bakaHomeworksProvider.notifier).refreshIfOld();
    //         Navigator.restorablePushNamed(
    //           context,
    //           '/bakalari-homeworks',
    //         );
    //       },
    //     ),
    //     NavigationSecondaryDestination(
    //       label: Text(loc.recentlyDeleted),
    //       icon: const Icon(Icons.delete_forever_outlined),
    //       onPressed: () {
    //         Navigator.restorablePushNamed(context, '/deleted');
    //       },
    //     ),
    //     NavigationSecondaryDestination(
    //       label: Text(loc.viewTutorial),
    //       icon: const Icon(Icons.school_outlined),
    //       onPressed: () {
    //         Navigator.restorablePushNamed(context, '/tutorial');
    //       },
    //     ),
    //     NavigationSecondaryDestination(
    //       label: Text(loc.settings),
    //       icon: const Icon(Icons.settings_outlined),
    //       onPressed: () {
    //         Navigator.restorablePushNamed(context, '/settings');
    //       },
    //     ),
    //   ],
    //   child: screens[page],
    // );

    final isDark = context.isDark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Stack(
        children: [
          MyShortcuts(
            child: Scaffold(
              key: _scaffoldKey,
              onDrawerChanged: (isOpened) {
                Posthog().capture(
                  eventName: 'Drawer ${isOpened ? 'opened' : 'closed'}',
                );
              },
              drawer: const MyDrawer(),
              bottomNavigationBar: isWide
                  ? null
                  : BottomNavBar(onTap: switchPage, pageIndex: page),
              body: Stack(
                children: [
                  SlidableAutoCloseBehavior(
                    child: Row(
                      children: [
                        if (isWide)
                          SideNavBar(onTap: switchPage, pageIndex: page),
                        WideScreenBorders(
                          show: isWide,
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: miliseconds),
                            switchInCurve: Curves.easeOutSine,
                            transitionBuilder: (child, animation) {
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
                            },
                            child: screens[page],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isWide)
                    IgnorePointer(
                      child: Container(
                        width: .infinity,
                        height: math.min(MediaQuery.paddingOf(context).top, 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              context.col.surface,
                              context.col.surface.withAlpha(0),
                            ],
                            begin: .topCenter,
                            end: .bottomCenter,
                          ),
                        ),
                      ),
                    ),
                  if (!isWide)
                    SafeArea(
                      child: Padding(
                        padding: const .all(8),
                        child: Align(
                          alignment: .topLeft,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: .circular(100),
                              boxShadow: kElevationToShadow[1],
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (!isWide)
                    SafeArea(
                      child: Padding(
                        padding: const .all(4),
                        child: Align(
                          alignment: .topLeft,
                          child: Badge(
                            alignment: const Alignment(0.4, -0.4),
                            isLabelVisible:
                                ref.watch(subjectsNonDeletedProvider).isEmpty ||
                                ref.watch(timetableProvider).periods.isEmpty,
                            backgroundColor: Colors.red,
                            child: M3EIconButton(
                              decoration: M3EButtonDecoration(
                                elevation: const WidgetStatePropertyAll(4),
                                backgroundColor: WidgetStatePropertyAll(
                                  context.col.surfaceContainer,
                                ),
                              ),
                              onPressed: openDrawer,
                              icon: const Icon(Icons.menu_rounded),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
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
      ),
    );
  }
}
