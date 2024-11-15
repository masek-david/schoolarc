import 'package:flutter/material.dart';
import 'package:school_manager/data/settings_database.dart';
import 'package:school_manager/notifications/notification_sender.dart';
import 'package:school_manager/screens/settings/setting_pages/tommorrow_notifications_page.dart';
import 'package:school_manager/screens/settings/widgets/drop_down_action.dart';
import 'package:school_manager/screens/settings/widgets/setting_tile.dart';
import 'package:school_manager/screens/settings/widgets/slider_action.dart';
import 'package:school_manager/screens/settings/widgets/switch_action.dart';
import 'package:school_manager/tasks_app.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({
    super.key,
    required this.setThemeMode,
  });

  final void Function(bool? value) setThemeMode;
  late final settings = SettingsDatabase();

  void showSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SettingTile(
            label: 'Upcoming day notifications',
            text: 'Notification with homeworks and exams for next day',
            icon: Icons.circle_notifications_outlined,
            onTap: () => navigatorKey.currentState
                ?.push(
              MaterialPageRoute(
                builder: (context) => TommorrowNotificationsPage(
                  settings: settings,
                ),
              ),
            )
                .then(
              (value) {
                NotificationSender.scheduleTommorrowNotification(
                    showSnackbar: (text) => showSnackBar(context, text));
              },
            ),
          ),
          SettingTile(
            label: 'Screen switching animation duration',
            text: 'In miliseconds',
            icon: Icons.timelapse,
            action: SliderAction(
              inititalValue: settings.get(Setting.pageSwitchAnimationDuration),
              divisions: 10,
              min: 0,
              max: 500,
              onChanged: (value) {
                settings.save(Setting.pageSwitchAnimationDuration, value);
              },
            ),
          ),
          SettingTile(
            label: 'Initial page',
            text: 'The page that will be initially opened',
            action: DropDownAction(
              items: const [
                DropdownMenuItem(value: 0, child: Text('Home')),
                DropdownMenuItem(value: 1, child: Text('Calendar')),
                DropdownMenuItem(value: 2, child: Text('Homeworks')),
                DropdownMenuItem(value: 3, child: Text('Exams')),
              ],
              initialValue: settings.get(Setting.initialAppPage),
              onChanged: (value) {
                settings.save(Setting.initialAppPage, value);
              },
            ),
          ),
          SettingTile(
            label: 'App theme',
            action: DropDownAction(
              initialValue: settings.get(Setting.themeMode),
              onChanged: (value) {
                bool? valueToBool = (value is bool) ? value : null;

                settings.save(Setting.themeMode, valueToBool);
                setThemeMode(valueToBool);
              },
              items: const [
                DropdownMenuItem(value: null, child: Text('System')),
                DropdownMenuItem(value: false, child: Text('Light')),
                DropdownMenuItem(value: true, child: Text('Dark')),
              ],
            ),
          ),
          SettingTile(
            label: 'Show debug info',
            action: SwitchAction(
              initialValue: settings.get(Setting.showDebugInfo),
              onChanged: (value) {
                settings.save(Setting.showDebugInfo, value);
              },
            ),
          )
        ],
      ),
    );
  }
}
