import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/screens/recap/recap_button.dart';
import 'package:schoolarc/screens/recap/recap_screen.dart';
import 'package:schoolarc/screens/settings/widgets/setting_tile.dart';
import 'package:schoolarc/utils/color_mapper.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/drawer/drawer_button.dart';
import 'package:schoolarc/widgets/drawer/search_bar.dart';

class MyDrawer extends ConsumerWidget {
  const MyDrawer({
    super.key,
    required this.startTutorial,
  });

  final void Function() startTutorial;

  void showSnackbar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      duration: const Duration(seconds: 10),
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool debugMode = ref.watch(debugModeProvider);
    final bool showFire = ref.watch(debugShowFireOverlayProvider);
    final bool showPerformance = ref.watch(debugShowPerformanceOverlayProvider);
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
                  colorMapper: LogoColorMapper(
                    isDark: Theme.of(context).brightness == Brightness.dark,
                    primaryFixedDimColor:
                        context.col.primaryFixedDim.toARGB32(),
                    secondaryColor: context.col.secondary.toARGB32(),
                  ),
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
                        Navigator.restorablePushNamed(context, '/subjects');
                      },
                    ),
                    MyDrawerButton(
                      text: loc.permanentTimetable,
                      icon: const Icon(Icons.calendar_month_outlined),
                      onTap: () {
                        Navigator.restorablePushNamed(
                            context, '/timetable');
                      },
                    ),
                    const Divider(indent: 28, endIndent: 28),
                    MyDrawerButton(
                      text: loc.hwFromBaka,
                      icon: const Icon(Icons.home_work_outlined),
                      onTap: () {
                        Navigator.restorablePushNamed(
                            context, '/bakalari-homeworks');
                      },
                    ),
                    const Divider(indent: 28, endIndent: 28),
                    MyDrawerButton(
                      text: loc.recentlyDeleted,
                      icon: const Icon(Icons.delete_forever),
                      onTap: () {
                        Navigator.restorablePushNamed(context, '/deleted');
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
                        value: showPerformance,
                        onChanged: (value) {
                          ref
                              .read(
                                  debugShowPerformanceOverlayProvider.notifier)
                              .set(value);
                        },
                      ),
                    if (debugMode)
                      SettingTile.withSwitch(
                        title: loc.showFirebaseOverlay,
                        value: showFire,
                        onChanged: (value) {
                          ref
                              .read(debugShowFireOverlayProvider.notifier)
                              .set(value);
                        },
                      ),
                    if (debugMode)
                      MyDrawerButton(
                        text: loc.viewDatabase,
                        icon: const Icon(Icons.data_array),
                        onTap: () {
                          Navigator.restorablePushNamed(context, '/database');
                        },
                      ),
                    if (debugMode)
                      MyDrawerButton(
                        text: loc.viewLogs,
                        icon: const Icon(Icons.bug_report),
                        onTap: () {
                          Navigator.restorablePushNamed(context, '/logs');
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
                Navigator.restorablePushNamed(context, '/settings');
              },
            ),
            if (debugMode || kDebugMode)
              GestureDetector(
                onTap: () => Navigator.restorablePushNamed(
                  context,
                  '/changelog',
                ),
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
              ),
          ],
        ),
      ),
    );
  }
}
