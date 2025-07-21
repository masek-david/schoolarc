import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/provider/debug_mode_notifier.dart';
import 'package:school_manager/screens/baka_homeworks/baka_homeworks_screen.dart';
import 'package:school_manager/screens/changelog_screen.dart';
import 'package:school_manager/screens/debug_info_screen.dart';
import 'package:school_manager/screens/logs/logs_screen.dart';
import 'package:school_manager/screens/recap/recap_button.dart';
import 'package:school_manager/screens/recap/recap_screen.dart';
import 'package:school_manager/screens/recently_deleted_screen.dart';
import 'package:school_manager/screens/settings/settings_screen.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/screens/subjects/subjects_screen.dart';
import 'package:school_manager/screens/timetable/timetable_screen.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/color_mapper.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';
import 'package:school_manager/widgets/drawer/drawer_button.dart';
import 'package:school_manager/widgets/drawer/search_bar.dart';

class MyDrawer extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    late final bool debugMode = ref.watch(debugModeProvider);
    final loc = context.loc;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                height: 100,
                child: SvgPicture.asset(
                  alignment: Alignment.centerLeft,
                  'assets/schoolarc_logo.svg',
                  colorMapper: LogoColorMapper(Theme.of(context)),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20, bottom: 16, right: 20),
              child: MySearchBar(),
            ),
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
                    if (kDebugMode || debugMode)
                      const Divider(indent: 28, endIndent: 28),
                    if (kDebugMode || debugMode)
                      SettingTile.withSwitch(
                        title: loc.developerMode,
                        value: debugMode,
                        onChanged: (value) {
                          ref.read(debugModeProvider.notifier).set(value);
                        },
                      ),
                    if (debugMode)
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
                    if (debugMode)
                      SettingTile.withSwitch(
                        title: loc.showFirebaseOverlay,
                        value: settings.get(Setting.debugShowFireOverlay),
                        onChanged: (value) {
                          settings.save(Setting.debugShowFireOverlay, value);
                          refreshTheme();
                        },
                      ),
                    if (debugMode)
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
                    if (debugMode)
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
            if (debugMode || kDebugMode)
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
