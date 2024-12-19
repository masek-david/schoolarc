import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:school_manager/screens/baka_homeworks.dart/baka_homeworks_screen.dart';
import 'package:school_manager/screens/meals/meals_screen.dart';
import 'package:school_manager/services/settings_database.dart';
import 'package:school_manager/screens/current_timetable/current_timetable.dart';
import 'package:school_manager/screens/debug_info_screen.dart';
import 'package:school_manager/screens/settings/settings_screen.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/screens/settings/widgets/switch_action.dart';
import 'package:school_manager/screens/subjects/subjects_screen.dart';
import 'package:school_manager/screens/timetable/timetable_screen.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/widgets/drawer/drawer_button.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({
    super.key,
    required this.setThemeMode,
    required this.startTutorial,
  });

  final void Function() setThemeMode;
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
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 28, bottom: 20, top: 20),
              child: Text('School app', style: TextStyle(fontSize: 20)),
            ),
            MyDrawerButton(
              text: 'Subjects',
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
              text: 'Timetable',
              icon: const Icon(Icons.calendar_month),
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
              text: 'Current Timetable',
              icon: const Icon(Icons.calendar_today_rounded),
              onTap: () {
                navigatorKey.currentState?.push(
                  MaterialPageRoute(
                    builder: (context) => const CurrentTimetableScreen(),
                  ),
                );
              },
            ),
            MyDrawerButton(
              text: 'Homeworks from Bakaláři',
              icon: const Icon(Icons.home_work_outlined),
              onTap: () {
                navigatorKey.currentState?.push(
                  MaterialPageRoute(
                    builder: (context) => BakaHomeworksScreen(),
                  ),
                );
              },
            ),
            const Divider(indent: 28, endIndent: 28),
            MyDrawerButton(
              text: 'Meals',
              icon: const Icon(Icons.food_bank_outlined),
              onTap: () {
                navigatorKey.currentState?.push(
                  MaterialPageRoute(
                    builder: (context) => MealsScreen(),
                  ),
                );
              },
            ),
            if (showDebug) const Divider(indent: 28, endIndent: 28),
            if (kDebugMode || showDebug)
              SettingTile(
                label: 'Show debug info',
                trailing: SwitchAction(
                  initialValue: settings.get(Setting.showDebugInfo),
                  onChanged: (value) {
                    settings.save(Setting.showDebugInfo, value);
                  },
                ),
              ),
            if (showDebug)
              MyDrawerButton(
                  text: 'View database',
                  icon: const Icon(Icons.data_array),
                  onTap: () {
                    navigatorKey.currentState?.push(
                      MaterialPageRoute(
                        builder: (context) => DbInfoScreen(),
                      ),
                    );
                  }),
            Spacer(),
            MyDrawerButton(
              text: 'View tutorial',
              icon: const Icon(Icons.school),
              onTap: startTutorial,
            ),
            MyDrawerButton(
              text: 'Settings',
              icon: const Icon(Icons.settings),
              onTap: () {
                navigatorKey.currentState?.push(
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(
                      refreshTheme: setThemeMode,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
