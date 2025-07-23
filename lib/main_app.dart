import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/provider/exam_notifier.dart';
import 'package:school_manager/provider/hw_notifier.dart';
import 'package:school_manager/provider/settings_notifiers.dart';
import 'package:school_manager/screens/main_screens/calendar/calendar_screen.dart';
import 'package:school_manager/screens/main_screens/exams/exams_screen.dart';
import 'package:school_manager/screens/main_screens/home/home_screen.dart';
import 'package:school_manager/screens/main_screens/homeworks/homeworks_screen.dart';
import 'package:school_manager/screens/tutorial/tutorial.dart';
import 'package:school_manager/services/home_widget_service.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';
import 'package:school_manager/utils/globals.dart';
import 'package:school_manager/utils/notifications/notification_controller.dart';
import 'package:school_manager/utils/notifications/notification_sender.dart';
import 'package:school_manager/widgets/drawer/my_drawer.dart';
import 'package:school_manager/widgets/firebase_overlay.dart';
import 'package:school_manager/widgets/my_shortcuts.dart';
import 'package:school_manager/widgets/navigation_bar/bottom_nav_bar.dart';
import 'package:school_manager/widgets/navigation_bar/side_nav_bar.dart';
import 'package:school_manager/widgets/time_format.dart';
import 'package:school_manager/widgets/wide_screen_borders.dart';

var _scaffoldKey = GlobalKey<ScaffoldState>();


void openDrawer() {
  _scaffoldKey.currentState?.openDrawer();
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  late final _pageController = PageController(
    initialPage: settings.get(Setting.initialAppPage),
  );
  late final AppLifecycleListener appStateListener;
  final Key _pageViewKey = GlobalKey();

  late int currentPageIndex = settings.get(Setting.initialAppPage);

  bool showingTutorial = false;

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
    NotificationSender.scheduletomorrowNotification();

    if (nowActive) {
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) {
          ref.read(examProvider.notifier).checkAllIfCompleted();
        },
      );
    }
  }

  void firstTimeOpeningApp() {
    if (!kIsWeb) {
      showingTutorial = true;
    }
  }

  void switchPage({required int newScreenIndex}) {
    double pageDiff =
        ((_pageController.page ?? 0) - newScreenIndex.toDouble()).abs();

    late final pageSwitchAnimationDuration = Duration(
      milliseconds:
          (settings.get(Setting.pageSwitchAnimationDuration) as double).toInt(),
    );

    if (pageSwitchAnimationDuration.inMilliseconds == 0 || pageDiff == 0.0) {
      _pageController.jumpToPage(newScreenIndex);
    } else {
      _pageController.animateToPage(
        newScreenIndex,
        curve: Curves.easeInOut,
        duration: pageSwitchAnimationDuration * pageDiff,
      );
    }

    setState(() {
      currentPageIndex = newScreenIndex;
    });
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
        tryGettingNewHomeworks(context);
      },
    );
  }

  @override
  void dispose() {
    appStateListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = context.isWide;

    return TimeFormat(
      child: Stack(
        children: [
          MyShortcuts(
            ref: ref,
            child: Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                toolbarHeight: 0,
                systemOverlayStyle: const SystemUiOverlayStyle(
                  systemNavigationBarColor: Colors.transparent,
                ),
              ),
              body: SlidableAutoCloseBehavior(
                child: Row(
                  children: [
                    if (isWide)
                      SideNavBar(
                        onTap: switchPage,
                        pageIndex: currentPageIndex,
                      ),
                    WideScreenBorders(
                      show: isWide && ref.watch(showAppBordersProvider),
                      child: PageView(
                        key: _pageViewKey,
                        physics: const NeverScrollableScrollPhysics(),
                        controller: _pageController,
                        children: const [
                          HomeScreen(),
                          CalendarScreen(
                            // TODO remove showtomorrow (get a key of it instead???)
                            showtomorrow: false,
                          ),
                          HomeworksScreen(),
                          ExamsScreen(),
                        ],
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
                      pageIndex: currentPageIndex,
                    ),
            ),
          ),
          if (showingTutorial) Tutorial(onEnd: endTutorial),
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
