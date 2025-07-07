import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:school_manager/screens/baka_homeworks/baka_homeworks_screen.dart';
import 'package:school_manager/screens/changelog_screen.dart';
import 'package:school_manager/screens/logs/logs_screen.dart';
import 'package:school_manager/screens/recap/recap_button.dart';
import 'package:school_manager/screens/recap/recap_screen.dart';
import 'package:school_manager/screens/recently_deleted_screen.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/screens/debug_info_screen.dart';
import 'package:school_manager/screens/settings/settings_screen.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/screens/subjects/subjects_screen.dart';
import 'package:school_manager/screens/timetable/timetable_screen.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';
import 'package:school_manager/widgets/drawer/drawer_button.dart';
import 'package:school_manager/widgets/drawer/search_bar.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({
    super.key,
    required this.refreshTheme,
    required this.startTutorial,
  });

  final void Function() refreshTheme;
  final void Function() startTutorial;

  void showSnackbar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      duration: const Duration(seconds: 10),
    ));
  }

  @override
  Widget build(BuildContext context) {
    late final bool showDebug = settings.get(Setting.showDebugInfo);
    final loc = context.loc;
    
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 28, bottom: 20, top: 20),
              child: Text('Schoolarc', style: TextStyle(fontSize: 20)),
            ),
            const Padding(
                padding: EdgeInsets.only(left: 20, bottom: 16, right: 20),
                child: MySearchBar()),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    MyDrawerButton(
                      text: loc.subjects,
                      icon: const Icon(Icons.school_outlined),
                      onTap: () {
                        navigatorKey.currentState?.push(
                          MaterialPageRoute(
                            builder: (context) => const SubjectsScreen(),
                          ),
                        );
                      },
                    ),
                    MyDrawerButton(
                      text: loc.permanentTimetable,
                      icon: const Icon(Icons.calendar_month_outlined),
                      onTap: () {
                        navigatorKey.currentState?.push(
                          MaterialPageRoute(
                            builder: (context) => const TimetableScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(indent: 28, endIndent: 28),
                    // MyDrawerButton(
                    //   text: 'Current Timetable',
                    //   icon: const Icon(Icons.calendar_today_rounded),
                    //   onTap: () {
                    //     navigatorKey.currentState?.push(
                    //       MaterialPageRoute(
                    //         builder: (context) =>
                    //             const CurrentTimetableScreen(),
                    //       ),
                    //     );
                    //   },
                    // ),
                    MyDrawerButton(
                      text: loc.hwFromBaka,
                      icon: const Icon(Icons.home_work_outlined),
                      onTap: () {
                        navigatorKey.currentState?.push(
                          MaterialPageRoute(
                            builder: (context) => const BakaHomeworksScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(indent: 28, endIndent: 28),
                    MyDrawerButton(
                      text: loc.recentlyDeleted,
                      icon: const Icon(Icons.delete_forever),
                      onTap: () {
                        navigatorKey.currentState?.push(
                          MaterialPageRoute(
                            builder: (context) => const RecentlyDeletedScreen(),
                          ),
                        );
                      },
                    ),
                    if (kDebugMode || showDebug)
                      const Divider(indent: 28, endIndent: 28),
                    if (kDebugMode || showDebug)
                      SettingTile.withSwitch(
                        title: loc.developerMode,
                        value: settings.get(Setting.showDebugInfo),
                        onChanged: (value) {
                          settings.save(Setting.showDebugInfo, value);
                          refreshTheme();
                        },
                      ),
                    if (showDebug)
                      SettingTile.withSwitch(
                        title: loc.showPerformanceOverlay,
                        value:
                            settings.get(Setting.debugShowPerformanceOverlay),
                        onChanged: (value) {
                          settings.save(
                              Setting.debugShowPerformanceOverlay, value);
                          refreshTheme();
                        },
                      ),
                    if (showDebug)
                      SettingTile.withSwitch(
                        title: loc.showFirebaseOverlay,
                        value: settings.get(Setting.debugShowFireOverlay),
                        onChanged: (value) {
                          settings.save(Setting.debugShowFireOverlay, value);
                          refreshTheme();
                        },
                      ),
                    if (showDebug)
                      MyDrawerButton(
                          text: loc.viewDatabase,
                          icon: const Icon(Icons.data_array),
                          onTap: () {
                            navigatorKey.currentState?.push(
                              MaterialPageRoute(
                                builder: (context) => DbInfoScreen(),
                              ),
                            );
                          }),
                    if (showDebug)
                      MyDrawerButton(
                        text: loc.viewLogs,
                        icon: const Icon(Icons.bug_report),
                        onTap: () {
                          navigatorKey.currentState?.push(
                            MaterialPageRoute(
                              builder: (context) => const LogsScreen(),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            if (isRecapDate())
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RecapButton(
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${loc.viewYearStats} 🎉',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            MyDrawerButton(
              text: loc.viewTutorial,
              icon: const Icon(Icons.school),
              onTap: startTutorial,
            ),
            MyDrawerButton(
              text: loc.settings,
              icon: const Icon(Icons.settings),
              onTap: () {
                navigatorKey.currentState?.push(
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(
                      refreshTheme: refreshTheme,
                    ),
                  ),
                );
              },
            ),
            if (showDebug || kDebugMode)
              GestureDetector(
                onTap: () => navigatorKey.currentState?.push(MaterialPageRoute(
                  builder: (context) => const ChangelogScreen(),
                )),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Text(
                    '${packageInfo.version} build ${packageInfo.buildNumber}',
                    style: TextStyle(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerLowest,
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
