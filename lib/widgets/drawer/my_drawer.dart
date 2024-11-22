import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:school_manager/data/settings_database.dart';
import 'package:school_manager/screens/bakalari/bakalari_screen.dart';
import 'package:school_manager/screens/current_timetable.dart/current_timetable.dart';
import 'package:school_manager/screens/db_info.dart';
import 'package:school_manager/screens/settings/settings_screen.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/screens/settings/widgets/switch_action.dart';
import 'package:school_manager/screens/strava_cz/strava_settings_screen.dart';
import 'package:school_manager/screens/subjects/subjects_screen.dart';
import 'package:school_manager/screens/timetable/timetable_screen.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/widgets/drawer/drawer_button.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({
    super.key,
    required this.setThemeMode,
  });

  final void Function(bool? value) setThemeMode;

  void showSnackbar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      duration: const Duration(seconds: 10),
    ));
  }

  @override
  Widget build(BuildContext context) {
    late final bool showDebug = settings.get(Setting.showDebugInfo);
    return NavigationDrawer(
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
          text: 'Bakalari',
          icon: const Icon(Icons.hexagon),
          onTap: () {
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => const BakalariScreen(),
              ),
            );
          },
        ),
        MyDrawerButton(
          text: 'Strava',
          icon: const Icon(Icons.food_bank_outlined),
          onTap: () {
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => const StravaSettingsScreen(),
              ),
            );
          },
        ),
        const Divider(indent: 28, endIndent: 28),
        MyDrawerButton(
          text: 'Settings',
          icon: const Icon(Icons.settings),
          onTap: () {
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => SettingsScreen(
                  setThemeMode: setThemeMode,
                ),
              ),
            );
          },
        ),
        if (showDebug) const Divider(indent: 28, endIndent: 28),
        if (kDebugMode)
          SettingTile(
            label: 'Show debug info',
            action: SwitchAction(
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
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DbInfoScreen(),
              ),
            ),
          ),
      ],
    );
  }
}
